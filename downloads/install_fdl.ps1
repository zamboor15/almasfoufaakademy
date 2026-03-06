# ═══════════════════════════════════════════════════════════
# §FDL§ مثبّت لغة فاضل — ويندوز (PowerShell)
# م. فاضل عباس الجعيفري — Codec Cosmic OS
#
# الاستخدام: powershell -ExecutionPolicy Bypass -File install_fdl.ps1
# ═══════════════════════════════════════════════════════════

$Version = "1.0.0"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  §FDL§ مثبّت لغة فاضل v$Version" -ForegroundColor Yellow
Write-Host "  م. فاضل عباس الجعيفري — Codec Cosmic OS" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

# === مسار التثبيت ===
$InstallDir = "$env:USERPROFILE\.fdl"
$DesktopDir = [Environment]::GetFolderPath("Desktop")

Write-Host "النظام: Windows $([Environment]::OSVersion.Version)"
Write-Host "مسار التثبيت: $InstallDir"
Write-Host ""

# === إنشاء المجلدات ===
Write-Host "=== 1: إنشاء المجلدات ===" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "$InstallDir" | Out-Null
New-Item -ItemType Directory -Force -Path "$InstallDir\projects" | Out-Null
New-Item -ItemType Directory -Force -Path "$InstallDir\extensions" | Out-Null
New-Item -ItemType Directory -Force -Path "$InstallDir\updates" | Out-Null
Write-Host "    تم"

# === نسخ الملفات ===
Write-Host ""
Write-Host "=== 2: نسخ الملفات ===" -ForegroundColor Cyan

# IDE
$IdeSource = Join-Path $ScriptDir "فاضل_IDE.html"
if (Test-Path $IdeSource) {
    Copy-Item $IdeSource "$InstallDir\" -Force
    Write-Host "    فاضل_IDE.html ← $InstallDir\"
} else {
    Write-Host "    خطأ: فاضل_IDE.html غير موجود!" -ForegroundColor Red
    exit 1
}

# المترجم
$CompilerSource = Join-Path $ScriptDir "المترجم.bin"
if (Test-Path $CompilerSource) {
    Copy-Item $CompilerSource "$InstallDir\" -Force
    Write-Host "    المترجم.bin ← $InstallDir\"
}

# المحمّل
$BootSource = Join-Path $ScriptDir "boot64.bin"
if (Test-Path $BootSource) {
    Copy-Item $BootSource "$InstallDir\" -Force
    Write-Host "    boot64.bin ← $InstallDir\"
}

# الأيقونة
$IconSource = Join-Path $ScriptDir "fdl_icon.svg"
if (Test-Path $IconSource) {
    Copy-Item $IconSource "$InstallDir\" -Force
    Write-Host "    fdl_icon.svg ← $InstallDir\"
}

# المنهاج
Get-ChildItem -Path $ScriptDir -Filter "*منهاج*" -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-Item $_.FullName "$InstallDir\" -Force
    Write-Host "    $($_.Name) ← $InstallDir\"
}

# === إنشاء أمر fdl.bat ===
Write-Host ""
Write-Host "=== 3: إنشاء أمر fdl ===" -ForegroundColor Cyan
$BatContent = @"
@echo off
chcp 65001 >nul 2>&1
set FDL_DIR=%USERPROFILE%\.fdl

if "%1"=="" goto ide
if "%1"=="--ide" goto ide
if "%1"=="--version" goto version
if "%1"=="--update" goto update
if "%1"=="--help" goto help
echo خطأ: أمر غير معروف '%1'
echo استخدم: fdl --help
goto end

:ide
echo §FDL§ — فتح بيئة التطوير...
start "" "%FDL_DIR%\فاضل_IDE.html"
goto end

:version
echo §FDL§ لغة فاضل v$Version
echo م. فاضل عباس الجعيفري
goto end

:update
echo §FDL§ — فحص التحديثات...
if exist "%FDL_DIR%\updates\تحديث.json" (
    type "%FDL_DIR%\updates\تحديث.json"
) else (
    echo لا توجد تحديثات
)
goto end

:help
echo §FDL§ — لغة فاضل
echo.
echo الاستخدام:
echo   fdl              فتح بيئة التطوير
echo   fdl --ide        فتح بيئة التطوير
echo   fdl --update     فحص التحديثات
echo   fdl --version    عرض الإصدار
echo   fdl --help       المساعدة
goto end

:end
"@
Set-Content -Path "$InstallDir\fdl.bat" -Value $BatContent -Encoding UTF8
Write-Host "    fdl.bat ← $InstallDir\"

# إضافة للمسار
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$InstallDir;$UserPath", "User")
    Write-Host "    أُضيف $InstallDir إلى PATH"
} else {
    Write-Host "    $InstallDir موجود في PATH"
}

# === ملف التحديث ===
Write-Host ""
Write-Host "=== 4: إعداد نظام التحديث ===" -ForegroundColor Cyan
$UpdateJson = @"
{
    "version": "$Version",
    "date": "$(Get-Date -Format 'yyyy-MM-dd')",
    "notes": "التثبيت الأول",
    "files": {
        "IDE": "فاضل_IDE.html",
        "compiler": "المترجم.bin",
        "bootloader": "boot64.bin"
    }
}
"@
Set-Content -Path "$InstallDir\updates\تحديث.json" -Value $UpdateJson -Encoding UTF8
Write-Host "    تحديث.json ← $InstallDir\updates\"

# سكربت التحديث
$UpdateScript = @'
# §FDL§ تطبيق التحديث
$FdlDir = "$env:USERPROFILE\.fdl"
$UpdateDir = "$FdlDir\updates"

Write-Host "§FDL§ — تطبيق التحديث" -ForegroundColor Yellow

# نسخة احتياطية
$Backup = "$UpdateDir\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Force -Path $Backup | Out-Null
Copy-Item "$FdlDir\فاضل_IDE.html" "$Backup\" -ErrorAction SilentlyContinue
Write-Host "نسخة احتياطية: $Backup"

# تطبيق
$Updated = $false
Get-ChildItem "$UpdateDir\*.html", "$UpdateDir\*.bin" -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-Item $_.FullName "$FdlDir\" -Force
    Write-Host "تحديث: $($_.Name)"
    $Updated = $true
}

if ($Updated) {
    Write-Host "تم التحديث بنجاح" -ForegroundColor Green
} else {
    Write-Host "لا توجد ملفات للتحديث"
}
'@
Set-Content -Path "$InstallDir\updates\apply_update.ps1" -Value $UpdateScript -Encoding UTF8
Write-Host "    apply_update.ps1 ← مطبّق التحديث"

# === اختصار سطح المكتب ===
Write-Host ""
Write-Host "=== 5: إنشاء اختصار سطح المكتب ===" -ForegroundColor Cyan
try {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$DesktopDir\§FDL§ فاضل.lnk")
    $Shortcut.TargetPath = "$InstallDir\فاضل_IDE.html"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "§FDL§ بيئة تطوير فاضل"
    $Shortcut.Save()
    Write-Host "    $DesktopDir\§FDL§ فاضل.lnk ← اختصار"
} catch {
    Write-Host "    تعذر إنشاء الاختصار (غير حرج)" -ForegroundColor Yellow
}

# === ربط امتداد .fdl ===
Write-Host ""
Write-Host "=== 6: ربط الامتدادات ===" -ForegroundColor Cyan
try {
    $RegPath = "HKCU:\Software\Classes\.fdl"
    New-Item -Path $RegPath -Force | Out-Null
    Set-ItemProperty -Path $RegPath -Name "(Default)" -Value "FDL.Source"

    $TypePath = "HKCU:\Software\Classes\FDL.Source"
    New-Item -Path $TypePath -Force | Out-Null
    Set-ItemProperty -Path $TypePath -Name "(Default)" -Value "FDL Source File"

    $OpenPath = "HKCU:\Software\Classes\FDL.Source\shell\open\command"
    New-Item -Path $OpenPath -Force | Out-Null
    Set-ItemProperty -Path $OpenPath -Name "(Default)" -Value """$InstallDir\fdl.bat"" --ide"

    Write-Host "    .fdl ← مرتبط بـ fdl"
} catch {
    Write-Host "    تعذر ربط الامتداد (غير حرج)" -ForegroundColor Yellow
}

# === النهاية ===
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  §FDL§ التثبيت اكتمل بنجاح!" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "  للبدء:" -ForegroundColor Green
Write-Host "    fdl              فتح بيئة التطوير" -ForegroundColor White
Write-Host "    fdl --help       عرض المساعدة" -ForegroundColor White
Write-Host "" -ForegroundColor Green
Write-Host "  الملفات:" -ForegroundColor Green
Write-Host "    $InstallDir\" -ForegroundColor White
Write-Host "" -ForegroundColor Green
Write-Host "  ملاحظة: أعد فتح الطرفية لتفعيل أمر fdl" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green

# فتح الواجهة
Write-Host ""
$Response = Read-Host "هل تريد فتح بيئة التطوير الآن؟ (ن/ل)"
if ($Response -eq "ن" -or $Response -eq "y" -or $Response -eq "Y") {
    Start-Process "$InstallDir\فاضل_IDE.html"
}
