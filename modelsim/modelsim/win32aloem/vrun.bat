@echo off

set PTH=%~d0%~p0

IF "%1" EQU "-help" (
    %PTH%\vish %PTH%\vrun.sh -c -help_vrun
) ELSE (
    %PTH%\vish %PTH%\vrun.sh -c %*
)
