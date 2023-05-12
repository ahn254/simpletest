using module ./software-report-base/SoftwareReport.psm1
using module ./software-report-base/SoftwareReport.Nodes.psm1

param (
    [Parameter(Mandatory)][string]
    $OutputDirectory
)

$global:ErrorActionPreference = "Continue"
$global:ErrorView = "NormalView"
Set-StrictMode -Off

Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Android.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Browsers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.CachedTools.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Common.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Databases.psm1") -DisableNameChecking
Import-Module "$PSScriptRoot/../helpers/SoftwareReport.Helpers.psm1" -DisableNameChecking
Import-Module "$PSScriptRoot/../helpers/Common.Helpers.psm1" -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Java.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Rust.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Tools.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.WebServers.psm1") -DisableNameChecking

# Restore file owner in user profile
Restore-UserOwner

# Software report
$softwareReport = [SoftwareReport]::new("Ubuntu $(Get-OSVersionShort)")
$softwareReport.Root.AddToolVersion("OS Version:", $(Get-OSVersionFull))
$softwareReport.Root.AddToolVersion("Kernel Version:", $(Get-KernelVersion))
$softwareReport.Root.AddToolVersion("Image Version:", $env:IMAGE_VERSION)
$softwareReport.Root.AddToolVersion("Systemd version:", $(Get-SystemdVersion))

$installedSoftware = $softwareReport.Root.AddHeader("Installed Software")

# Language and Runtime
$languageAndRuntime = $installedSoftware.AddHeader("Language and Runtime")
Write-Host "bash"
$languageAndRuntime.AddToolVersion("Bash", $(Get-BashVersion))
Write-Host "Clang"
$languageAndRuntime.AddToolVersionsListInline("Clang", $(Get-ClangToolVersions -ToolName "clang"), "^\d+")
Write-Host "clang-format"
$languageAndRuntime.AddToolVersionsListInline("Clang-format", $(Get-ClangToolVersions -ToolName "clang-format"), "^\d+")
Write-Host "clang-tidy"
$languageAndRuntime.AddToolVersionsListInline("Clang-tidy", $(Get-ClangTidyVersions), "^\d+")
Write-Host "dash"
$languageAndRuntime.AddToolVersion("Dash", $(Get-DashVersion))
if (Test-IsUbuntu20) {
    Write-Host "erlang"
    $languageAndRuntime.AddToolVersion("Erlang", $(Get-ErlangVersion))
    Write-Host "erlang rebar3"
    $languageAndRuntime.AddToolVersion("Erlang rebar3", $(Get-ErlangRebar3Version))
}
Write-Host "gnu C++"
$languageAndRuntime.AddToolVersionsListInline("GNU C++", $(Get-CPPVersions), "^\d+")
Write-Host "gnu fortran"
$languageAndRuntime.AddToolVersionsListInline("GNU Fortran", $(Get-FortranVersions), "^\d+")
Write-Host "julia"
$languageAndRuntime.AddToolVersion("Julia", $(Get-JuliaVersion))
Write-Host "kotlin"
$languageAndRuntime.AddToolVersion("Kotlin", $(Get-KotlinVersion))
Write-Host "mono"
$languageAndRuntime.AddToolVersion("Mono", $(Get-MonoVersion))
Write-Host "msbuild"
$languageAndRuntime.AddToolVersion("MSBuild", $(Get-MsbuildVersion))
Write-Host "node.js"
$languageAndRuntime.AddToolVersion("Node.js", $(Get-NodeVersion))
Write-Host "perl"
$languageAndRuntime.AddToolVersion("Perl", $(Get-PerlVersion))
Write-Host "Python"
$languageAndRuntime.AddToolVersion("Python", $(Get-PythonVersion))
Write-Host "Python3"
$languageAndRuntime.AddToolVersion("Python3", $(Get-Python3Version))
Write-Host "ruby"
$languageAndRuntime.AddToolVersion("Ruby", $(Get-RubyVersion))
Write-Host "Swift"
$languageAndRuntime.AddToolVersion("Swift", $(Get-SwiftVersion))

# Package Management
$packageManagement = $installedSoftware.AddHeader("Package Management")
Write-Host "cpan"
$packageManagement.AddToolVersion("cpan", $(Get-CpanVersion))
Write-Host "helm"
$packageManagement.AddToolVersion("Helm", $(Get-HelmVersion))
Write-Host "homebrew"
$packageManagement.AddToolVersion("Homebrew", $(Get-HomebrewVersion))
Write-Host "miniconda"
$packageManagement.AddToolVersion("Miniconda", $(Get-MinicondaVersion))
Write-Host "npm"
$packageManagement.AddToolVersion("Npm", $(Get-NpmVersion))
Write-Host "nuget"
$packageManagement.AddToolVersion("NuGet", $(Get-NuGetVersion))
Write-Host "pip"
$packageManagement.AddToolVersion("Pip", $(Get-PipVersion))
Write-Host "pip3"
$packageManagement.AddToolVersion("Pip3", $(Get-Pip3Version))
Write-Host "pipx"
$packageManagement.AddToolVersion("Pipx", $(Get-PipxVersion))
Write-Host "rubygems"
$packageManagement.AddToolVersion("RubyGems", $(Get-GemVersion))
Write-Host "vcpkg"
$packageManagement.AddToolVersion("Vcpkg", $(Get-VcpkgVersion))
Write-Host "yarn"
$packageManagement.AddToolVersion("Yarn", $(Get-YarnVersion))
$packageManagement.AddHeader("Environment variables").AddTable($(Build-PackageManagementEnvironmentTable))
$packageManagement.AddHeader("Homebrew note").AddNote(@'
Location: /home/linuxbrew
Note: Homebrew is pre-installed on image but not added to PATH.
run the eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" command
to accomplish this.
'@)

# Project Management
$projectManagement = $installedSoftware.AddHeader("Project Management")
if (Test-IsUbuntu20) {
    Write-Host "ant"
    $projectManagement.AddToolVersion("Ant", $(Get-AntVersion))
    Write-Host "gradle"
    $projectManagement.AddToolVersion("Gradle", $(Get-GradleVersion))
}
if ((Test-IsUbuntu20) -or (Test-IsUbuntu22)) {
    Write-Host "lerna"
    $projectManagement.AddToolVersion("Lerna", $(Get-LernaVersion))
}
Write-Host "maven"
$projectManagement.AddToolVersion("Maven", $(Get-MavenVersion))
if (Test-IsUbuntu20) {
    Write-Host "sbt"
    $projectManagement.AddToolVersion("Sbt", $(Get-SbtVersion))
}

# Tools
$tools = $installedSoftware.AddHeader("Tools")
Write-Host "ansible"
$tools.AddToolVersion("Ansible", $(Get-AnsibleVersion))
Write-Host "apt-fast"
$tools.AddToolVersion("apt-fast", $(Get-AptFastVersion))
Write-Host "azcopy"
$tools.AddToolVersion("AzCopy", $(Get-AzCopyVersion))
Write-Host "bazel"
$tools.AddToolVersion("Bazel", $(Get-BazelVersion))
Write-Host "bazelisk"
$tools.AddToolVersion("Bazelisk", $(Get-BazeliskVersion))
Write-Host "bicep"
$tools.AddToolVersion("Bicep", $(Get-BicepVersion))
Write-Host "buildan"
$tools.AddToolVersion("Buildah", $(Get-BuildahVersion))
Write-Host "cmake"
$tools.AddToolVersion("CMake", $(Get-CMakeVersion))
Write-Host "codeql"
$tools.AddToolVersion("CodeQL Action Bundles", $(Get-CodeQLBundleVersions))
Write-Host "docker amazon"
$tools.AddToolVersion("Docker Amazon ECR Credential Helper", $(Get-DockerAmazonECRCredHelperVersion))
Write-Host "docker compose v1"
$tools.AddToolVersion("Docker Compose v1", $(Get-DockerComposeV1Version))
Write-Host "Docker compose v2"
$tools.AddToolVersion("Docker Compose v2", $(Get-DockerComposeV2Version))
Write-Host "docker-buildx"
$tools.AddToolVersion("Docker-Buildx", $(Get-DockerBuildxVersion))
Write-Host "docker-moby client"
$tools.AddToolVersion("Docker-Moby Client", $(Get-DockerMobyClientVersion))
Write-Host "docker-moby server"
$tools.AddToolVersion("Docker-Moby Server", $(Get-DockerMobyServerVersion))
if ((Test-IsUbuntu20) -or (Test-IsUbuntu22)) {
    Write-Host "fastlane"
    $tools.AddToolVersion("Fastlane", $(Get-FastlaneVersion))
}
Write-Host "git"
$tools.AddToolVersion("Git", $(Get-GitVersion))
Write-Host "git lfs"
$tools.AddToolVersion("Git LFS", $(Get-GitLFSVersion))
Write-Host "git-ftp"
$tools.AddToolVersion("Git-ftp", $(Get-GitFTPVersion))
Write-Host "haveged"
$tools.AddToolVersion("Haveged", $(Get-HavegedVersion))
Write-Host "heroku"
$tools.AddToolVersion("Heroku", $(Get-HerokuVersion))
if (Test-IsUbuntu20) {
    Write-Host "hhvm"
    $tools.AddToolVersion("HHVM (HipHop VM)", $(Get-HHVMVersion))
}
Write-Host "jq"
$tools.AddToolVersion("jq", $(Get-JqVersion))
Write-Host "kind"
$tools.AddToolVersion("Kind", $(Get-KindVersion))
Write-Host "kubctl"
$tools.AddToolVersion("Kubectl", $(Get-KubectlVersion))
Write-Host "kustomize"
$tools.AddToolVersion("Kustomize", $(Get-KustomizeVersion))
Write-Host "leiningen"
$tools.AddToolVersion("Leiningen", $(Get-LeiningenVersion))
Write-Host "mediainfo"
$tools.AddToolVersion("MediaInfo", $(Get-MediainfoVersion))
Write-Host "mercurial"
$tools.AddToolVersion("Mercurial", $(Get-HGVersion))
Write-Host "minikube"
$tools.AddToolVersion("Minikube", $(Get-MinikubeVersion))
Write-Host "n"
$tools.AddToolVersion("n", $(Get-NVersion))
Write-Host "newman"
$tools.AddToolVersion("Newman", $(Get-NewmanVersion))
Write-Host "nvm"
$tools.AddToolVersion("nvm", $(Get-NvmVersion))
Write-Host "openssl"
$tools.AddToolVersion("OpenSSL", $(Get-OpensslVersion))
Write-Host "packer"
$tools.AddToolVersion("Packer", $(Get-PackerVersion))
Write-Host "parcel"
$tools.AddToolVersion("Parcel", $(Get-ParcelVersion))
if (Test-IsUbuntu20) {
    Write-Host "phantomjs"
    $tools.AddToolVersion("PhantomJS", $(Get-PhantomJSVersion))
}
Write-Host "podman"
$tools.AddToolVersion("Podman", $(Get-PodManVersion))
Write-Host "pulumi"
$tools.AddToolVersion("Pulumi", $(Get-PulumiVersion))
Write-Host "r"
$tools.AddToolVersion("R", $(Get-RVersion))
Write-Host "skopeo"
$tools.AddToolVersion("Skopeo", $(Get-SkopeoVersion))
Write-Host "sphinx open source"
$tools.AddToolVersion("Sphinx Open Source Search Server", $(Get-SphinxVersion))
Write-Host "svn"
$tools.AddToolVersion("SVN", $(Get-SVNVersion))
Write-Host "terraform"
$tools.AddToolVersion("Terraform", $(Get-TerraformVersion))
Write-Host "yamlint"
$tools.AddToolVersion("yamllint", $(Get-YamllintVersion))
Write-Host "yq"
$tools.AddToolVersion("yq", $(Get-YqVersion))
Write-Host "zstd"
$tools.AddToolVersion("zstd", $(Get-ZstdVersion))

# CLI Tools
$cliTools = $installedSoftware.AddHeader("CLI Tools")
Write-Host "alibaba cloud"
$cliTools.AddToolVersion("Alibaba Cloud CLI", $(Get-AlibabaCloudCliVersion))
Write-Host "aws cli"
$cliTools.AddToolVersion("AWS CLI", $(Get-AWSCliVersion))
Write-Host "aws cli session"
$cliTools.AddToolVersion("AWS CLI Session Manager Plugin", $(Get-AWSCliSessionManagerPluginVersion))
Write-Host "aws sam cli"
$cliTools.AddToolVersion("AWS SAM CLI", $(Get-AWSSAMVersion))
Write-Host "azure cli"
$cliTools.AddToolVersion("Azure CLI", $(Get-AzureCliVersion))
Write-Host "azure cli devops"
$cliTools.AddToolVersion("Azure CLI (azure-devops)", $(Get-AzureDevopsVersion))
Write-Host "github cli"
$cliTools.AddToolVersion("GitHub CLI", $(Get-GitHubCliVersion))
Write-Host "google cloud sdk"
$cliTools.AddToolVersion("Google Cloud SDK", $(Get-GoogleCloudSDKVersion))
Write-Host "hub cli"
$cliTools.AddToolVersion("Hub CLI", $(Get-HubCliVersion))
Write-Host "netlify cli"
$cliTools.AddToolVersion("Netlify CLI", $(Get-NetlifyCliVersion))
Write-Host "openshift cli"
$cliTools.AddToolVersion("OpenShift CLI", $(Get-OCCliVersion))
Write-Host "oras cli"
$cliTools.AddToolVersion("ORAS CLI", $(Get-ORASCliVersion))
Write-Host "vercel cli"
$cliTools.AddToolVersion("Vercel CLI", $(Get-VerselCliversion))

Write-Host "java"
$installedSoftware.AddHeader("Java").AddTable($(Get-JavaVersionsTable))

$phpTools = $installedSoftware.AddHeader("PHP Tools")
Write-Host "php"
$phpTools.AddToolVersionsListInline("PHP", $(Get-PHPVersions), "^\d+\.\d+")
Write-Host "composer"
$phpTools.AddToolVersion("Composer", $(Get-ComposerVersion))
Write-Host "phpunit"
$phpTools.AddToolVersion("PHPUnit", $(Get-PHPUnitVersion))
Write-Host "both xdebug and pcov"
$phpTools.AddNote("Both Xdebug and PCOV extensions are installed, but only Xdebug is enabled.")

$haskellTools = $installedSoftware.AddHeader("Haskell Tools")
Write-Host "cabal"
$haskellTools.AddToolVersion("Cabal", $(Get-CabalVersion))
Write-Host "ghc"
$haskellTools.AddToolVersion("GHC", $(Get-GHCVersion))
Write-Host "ghcup"
$haskellTools.AddToolVersion("GHCup", $(Get-GHCupVersion))
Write-Host "stack"
$haskellTools.AddToolVersion("Stack", $(Get-StackVersion))

Initialize-RustEnvironment
Write-Host "rust tools"
$rustTools = $installedSoftware.AddHeader("Rust Tools")
Write-Host "cargo"
$rustTools.AddToolVersion("Cargo", $(Get-CargoVersion))
Write-Host "rust"
$rustTools.AddToolVersion("Rust", $(Get-RustVersion))
Write-Host "rustdoc"
$rustTools.AddToolVersion("Rustdoc", $(Get-RustdocVersion))
Write-Host "rustup"
$rustTools.AddToolVersion("Rustup", $(Get-RustupVersion))
$rustToolsPackages = $rustTools.AddHeader("Packages")
Write-Host "bindgen"
$rustToolsPackages.AddToolVersion("Bindgen", $(Get-BindgenVersion))
Write-Host "cargo audit"
$rustToolsPackages.AddToolVersion("Cargo audit", $(Get-CargoAuditVersion))
Write-Host "cargo clippy"
$rustToolsPackages.AddToolVersion("Cargo clippy", $(Get-CargoClippyVersion))
Write-Host "cargo outdate"
$rustToolsPackages.AddToolVersion("Cargo outdated", $(Get-CargoOutdatedVersion))
Write-Host "cbindgen"
$rustToolsPackages.AddToolVersion("Cbindgen", $(Get-CbindgenVersion))
Write-Host "rustfmt"
$rustToolsPackages.AddToolVersion("Rustfmt", $(Get-RustfmtVersion))

$browsersTools = $installedSoftware.AddHeader("Browsers and Drivers")
Write-Host "google chrome"
$browsersTools.AddToolVersion("Google Chrome", $(Get-ChromeVersion))
Write-Host "chromedriver"
$browsersTools.AddToolVersion("ChromeDriver", $(Get-ChromeDriverVersion))
Write-Host "chromium"
$browsersTools.AddToolVersion("Chromium", $(Get-ChromiumVersion))
Write-Host "microsoft edge"
$browsersTools.AddToolVersion("Microsoft Edge", $(Get-EdgeVersion))
Write-Host "microsoft edge webdrv"
$browsersTools.AddToolVersion("Microsoft Edge WebDriver", $(Get-EdgeDriverVersion))
Write-Host "selenium server"
$browsersTools.AddToolVersion("Selenium server", $(Get-SeleniumVersion))
Write-Host "mozilla firefox"
$browsersTools.AddToolVersion("Mozilla Firefox", $(Get-FirefoxVersion))
Write-Host "geckodriver"
$browsersTools.AddToolVersion("Geckodriver", $(Get-GeckodriverVersion))
Write-Host "env var"
$browsersTools.AddHeader("Environment variables").AddTable($(Build-BrowserWebdriversEnvironmentTable))

$netCoreTools = $installedSoftware.AddHeader(".NET Tools")
Write-Host "net core sdk"
$netCoreTools.AddToolVersionsListInline(".NET Core SDK", $(Get-DotNetCoreSdkVersions), "^\d+\.\d+\.\d")
$netCoreTools.AddNodes($(Get-DotnetTools))

$databasesTools = $installedSoftware.AddHeader("Databases")
if (Test-IsUbuntu20) {
    Write-Host "mongodb"
    $databasesTools.AddToolVersion("MongoDB", $(Get-MongoDbVersion))
}
Write-Host "sqlite3"
$databasesTools.AddToolVersion("sqlite3", $(Get-SqliteVersion))
$databasesTools.AddNode($(Build-PostgreSqlSection))
$databasesTools.AddNode($(Build-MySQLSection))
$databasesTools.AddNode($(Build-MSSQLToolsSection))

$cachedTools = $installedSoftware.AddHeader("Cached Tools")
Write-Host "go"
$cachedTools.AddToolVersionsList("Go", $(Get-ToolcacheGoVersions), "^\d+\.\d+")
Write-Host "node.js"
$cachedTools.AddToolVersionsList("Node.js", $(Get-ToolcacheNodeVersions), "^\d+")
Write-Host "python"
$cachedTools.AddToolVersionsList("Python", $(Get-ToolcachePythonVersions), "^\d+\.\d+")
Write-Host "pypy"
$cachedTools.AddToolVersionsList("PyPy", $(Get-ToolcachePyPyVersions), "^\d+\.\d+")
Write-Host "ruby"
$cachedTools.AddToolVersionsList("Ruby", $(Get-ToolcacheRubyVersions), "^\d+\.\d+")

$powerShellTools = $installedSoftware.AddHeader("PowerShell Tools")
Write-Host "powershell"
$powerShellTools.AddToolVersion("PowerShell", $(Get-PowershellVersion))
Write-Host "powershell module"
$powerShellTools.AddHeader("PowerShell Modules").AddNodes($(Get-PowerShellModules))
Write-Host "webservers"
$installedSoftware.AddHeader("Web Servers").AddTable($(Build-WebServersTable))
Write-Host "android"
$androidTools = $installedSoftware.AddHeader("Android")
$androidTools.AddTable($(Build-AndroidTable))
$androidTools.AddHeader("Environment variables").AddTable($(Build-AndroidEnvironmentTable))
Write-Host "cache docker"
$installedSoftware.AddHeader("Cached Docker images").AddTable($(Get-CachedDockerImagesTableData))
Write-Host "installed apt pack"
$installedSoftware.AddHeader("Installed apt packages").AddTable($(Get-AptPackages))

$softwareReport.ToJson() | Out-File -FilePath "${OutputDirectory}/software-report.json" -Encoding UTF8NoBOM
$softwareReport.ToMarkdown() | Out-File -FilePath "${OutputDirectory}/software-report.md" -Encoding UTF8NoBOM
