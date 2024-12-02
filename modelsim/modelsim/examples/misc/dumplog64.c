#include <stdlib.h>
#include <stdio.h>
#include "wlf_api.h"

extern char * strcpy(char *dst, const char *src);

#define MAX_VALUE_SIZE 10000

/* structure to hold callback data */
typedef struct cbData {
    WlfSymbolId  sym;
    WlfValueId   val;
} cbData;

WlfPackId pack;


/******************************************************************************
//  errorExit
//  Prints error message to stderr and exits.
******************************************************************************/
static void errorExit( char *funcName )
{
    int errorNum = wlfErrorNum();
    fprintf(stderr, "Error: %s - %d - %s\n", 
            funcName, wlfErrorNum(), wlfErrorMsg());
    exit( errorNum );
}

/******************************************************************************
//  AddSymbolToList
//  Adds a symbol to the symbol list 
//  Note that CHECK_UNIQUE is not needed as this is called from an iterator
//  which will guarantee that the signals are unique.  Plus, this would 
//  result in an n^2 performance penalty.
******************************************************************************/
static WlfSymbolListId AddSymbolToList( 
    WlfSymbolListId head, 
    WlfSymbolListId tail,
    WlfSymbolId sym, 
    char * data)
{
#ifdef CHECK_UNIQUE
    WlfSymbolListId  tlist;
    /* if symbol is already in list, don't add it */
    for( tlist = head; tlist != NULL; tlist = tlist->next) {
        if ( wlfCompareSymbols( sym, tlist->symbolId) ) return tail;
    }
#endif
    return wlfSymbolListAppend( tail, sym, data);
}

/******************************************************************************
//  printSubElements
//  Recursively prints the context tree information starting at the top and
//  adds elements to the symbol list.
******************************************************************************/
static void printSubElements( 
    WlfSymbolId top, 
    WlfSymbolListId head, 
    WlfSymbolListId *tail )
{
    WlfIterId iter;
    WlfSymbolId sym;
    int status;
    int cnt;
    char *name;

    /* create an iterator to retrieve children of top */
    iter = wlfSymChildren64( top, wlfSelAll );
    if ( iter == NULL ) return;

    /* interate through the children */
    while ( (sym = wlfIterate( iter)) != NULL ) {
        /* add the symbol to the symbollist */
        *tail = AddSymbolToList( head, *tail, sym, NULL);

        /* print information about the symbol */
        cnt = wlfSymPropInt( sym, WLF_PROP_SUBELEMENT_COUNT);
        name = wlfSymPropString( sym, WLF_PROP_SYMBOL_FULLNAME);
        if ( cnt > 0 ) {
            printf("Obj = %s\t\t SubElemCnt = %d\n", name, cnt);
        } else {
            printf("Obj = %s\n", name);
        }

        /* recurse through the children */
        printSubElements( sym, head, tail);
    }
    status = wlfIteratorDestroy(iter);
}

/******************************************************************************
//  timeCb
//  This function is called by the WLF reader when time advances.
//  Note that the time and delta are that of the -completed- time and delta,
//  not the next time and delta.
//  In this case, the scan is just continued.
******************************************************************************/
static WlfCallbackResponse timeCb( 
    void *cbData, 
    WlfTime64 oldTime, 
    int oldDelta)
{
    return( WLF_CONTINUE_SCAN);
}

/******************************************************************************
//  sigCb
//  This function prints the time, the name of the signal, and its value.
//  This function is called by the WLF reader as events occur on 
//  registered signals.  This function was registered with each signal 
//  in addSignalCb().  (See the call to wlfAddSignalEventCB().)
******************************************************************************/
static WlfCallbackResponse sigCb( 
    void *data, 
    WlfCallbackReason reason)
{
    WlfValueId v = ((cbData*) data)->val;
    WlfSymbolId s = ((cbData*) data)->sym;
    WlfRadixEnum radix = WLF_RADIX_SYMBOLIC;
    WlfTime64 time;
    char *f, fname[1024], value[MAX_VALUE_SIZE];

    if (reason != WLF_EVENT)
        return WLF_CONTINUE_SCAN;

    wlfPackTime( pack, &time);
    
    if ((f=wlfSymPropString(s, WLF_PROP_SYMBOL_FULLNAME))!=NULL)
        strcpy(fname,f);

    if ((f=wlfValueToString( v, radix, MAX_VALUE_SIZE-1 ))!=NULL)
        strcpy(value,f);

    printf("%d\t%s\t%s\n",
           WLF_TIME64_LO32(time),
           fname ? fname : "NULL",
           value ? value : "NULL" );
    return( WLF_CONTINUE_SCAN);
}

/******************************************************************************
//  addSignalCb
//  Adds WLF signal event callbacks for each signal in the symbol list.
******************************************************************************/
static void addSignalCb( 
    WlfSymbolId top, 
    WlfPackId pack, 
    WlfValueId val, 
    WlfSymbolListId head)
{
    WlfSymbolId sym;
    int status;
    cbData *pdata;
    WlfSymbolListId tlist;

    for( tlist = head;tlist != NULL; tlist = tlist->next) {
        sym = tlist->symbolId;
        if ( ! sym) break;
        if ( wlfSymIsSymbolSelect64( sym, wlfSelAllSignals)) {
            val = wlfValueCreate( sym );
            pdata = (cbData *) malloc( sizeof( cbData));
            pdata->sym = sym;
            pdata->val = val;
            status = wlfAddSignalEventCB( pack, 
                sym, val, WLF_REQUEST_POSTPONED, sigCb, pdata);
            if ( status != WLF_OK)
                errorExit("addSignalCb");
        }
    }
}

/******************************************************************************
//  main
******************************************************************************/
int main( int argc, char **argv)
{
    int status;
    int resolution;
    WlfFileId  wlfFile;
    WlfSymbolId top;
    WlfTime64 startTime, stopTime;
    WlfValueId val = NULL;
    WlfSymbolListId  head, tail;
    WlfFileInfo  fileInfo;

    if ( argc < 2 ) {
        fprintf(stderr,"Usage: %s <WLF-file>\n", argv[0]);
        exit(1);
    }

    /* Initialize the WLF api */
    status = wlfInit();
    if ( status != WLF_OK )
        errorExit("wlfInit");

    /* Open the WLF File */
    wlfFile = wlfFileOpen( argv[1], "vsim_wlf");
    if ( wlfFile == NULL )
        errorExit("wlfFileOpen");

    /* Check the API version */
    status = wlfFileInfo( wlfFile, &fileInfo);
    if ( status != WLF_OK )
        errorExit("wlfFileInfo");
    printf("WLF api version=%s\n", fileInfo.apiVersion);
    printf("WLF header file version=%s\n", WLF_API_VERSION);
  
    /* Get the simulator resolution */
    status = wlfFileResolution( wlfFile, &resolution );
    if ( status != WLF_OK )
        errorExit("wlfFileResolution");

    /* Retrieve and print out the top level context for this wlf file */
    top = wlfFileGetTopContext( wlfFile );
    if ( top == NULL )
        errorExit("wlfFileGetTopContext");

    printf("Top Context = %s\t Resolution=%d\n", 
           wlfSymPropString( top, WLF_PROP_SYMBOL_FULLNAME),
           resolution);
 
    /* initialize a symbollist */
    head = tail = NULL;
    status = wlfSymbolListInit( &head, &tail, top, NULL);
    if ( status != WLF_OK )
        errorExit("wlfSymbolListInit");

    /* print out symbol information */
    printSubElements( top, head, &tail );

    /* Create a callback context  */
    pack = wlfPackCreate();
    if (pack == NULL)
        errorExit("wlfPackCreate");
    
    /* Add a callback for each signal, the callback function will be called
     * when the scan detects an event on the signal.
     */
    addSignalCb( top, pack, val, head);

    /* Scan the data starting at time 0 through the end of file */
    WLF_TIME64_ASGN(startTime, 0, 0);
    WLF_TIME64_ASGN(stopTime, 0x7FFFFFFF, ~0U);
    status = wlfReadDataOverRange( pack, 
        startTime, 0, stopTime, 100, NULL, timeCb, NULL);
    if ( status != WLF_OK )
        errorExit("wlfReadDataOverRange");

    /* close the file and release resources */
    status  = wlfFileClose( wlfFile );
    if ( status != WLF_OK )
        errorExit("wlfFileClose");

    status = wlfCleanup();
    if ( status != WLF_OK )
        errorExit("wlfCleanup");

    return status;
}
