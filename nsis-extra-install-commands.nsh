!define ARP "Software\Microsoft\Windows\CurrentVersion\Uninstall\"

${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
IntFmt $0 "0x%08X" $0
WriteRegDWORD HKLM "${ARP}" "EstimatedSize" "$0"

${RegisterExtension} "$INSTDIR\openscad.exe" ".scad" "OpenSCAD_File"
${RefreshShellIcons}
