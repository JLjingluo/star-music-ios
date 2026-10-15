#!/usr/bin/env python3
"""Generate a dependency-free Xcode project mirroring project.yml.
XcodeGen remains the authoritative generator used by CI.
"""
from pathlib import Path
import hashlib,json
root=Path(__file__).resolve().parent.parent
project=root/'StarMusic.xcodeproj'
project.mkdir(exist_ok=True)
def ident(name):return hashlib.sha256(name.encode()).hexdigest()[:24].upper()
def q(value):return json.dumps(value,ensure_ascii=False)
objects=[]
def obj(name,isa,body):
    identifier=ident(name)
    objects.append(f'{identifier} = {{ isa = {isa}; {body} }};')
    return identifier
def refs(ids):return '('+','.join(ids)+',)' if ids else '()'
app_files=sorted((root/'StarMusic').glob('*.swift'))
source_ids=[];build_ids=[]
for path in app_files:
    source_ids.append(obj('file:'+path.name,'PBXFileReference',f'lastKnownFileType = sourcecode.swift; path = {q(path.name)}; sourceTree = "<group>";'))
    build_ids.append(obj('build:'+path.name,'PBXBuildFile',f'fileRef = {ident("file:"+path.name)};'))
model_file=obj('crepe-model','PBXFileReference','lastKnownFileType = folder.mlpackage; path = Resources/PitchCREPE.mlpackage; sourceTree = "<group>";')
model_build=obj('crepe-build','PBXBuildFile',f'fileRef = {model_file};')
build_ids.append(model_build)
notice_ids=[];notice_builds=[]
for filename in ['CREPE-LICENSE.txt','MODEL-MANIFEST.json']:
    ref=obj('resource:'+filename,'PBXFileReference',f'lastKnownFileType = text; path = Resources/{filename}; sourceTree = "<group>";')
    notice_ids.append(ref);notice_builds.append(obj('resourcebuild:'+filename,'PBXBuildFile',f'fileRef = {ref};'))
launch_file=obj('launchfile','PBXFileReference','lastKnownFileType = file.storyboard; path = LaunchScreen.storyboard; sourceTree = "<group>";')
launch_build=obj('launchbuild','PBXBuildFile',f'fileRef = {launch_file};')
entitlements=obj('sim-entitlements','PBXFileReference','lastKnownFileType = text.plist.entitlements; path = Simulator.entitlements; sourceTree = "<group>";')
test_file=obj('testfile','PBXFileReference','lastKnownFileType = sourcecode.swift; path = MusicTests.swift; sourceTree = "<group>";')
test_build=obj('testbuild','PBXBuildFile',f'fileRef = {test_file};')
asset=obj('asset','PBXFileReference','lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>";')
privacy=obj('privacy','PBXFileReference','lastKnownFileType = text.xml; path = PrivacyInfo.xcprivacy; sourceTree = "<group>";')
privacy_build=obj('privacybuild','PBXBuildFile',f'fileRef = {privacy};')
asset_build=obj('assetbuild','PBXBuildFile',f'fileRef = {asset};')
plist=obj('plist','PBXFileReference','lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>";')
app_product=obj('app-product','PBXFileReference','explicitFileType = wrapper.application; includeInIndex = 0; path = StarMusic.app; sourceTree = BUILT_PRODUCTS_DIR;')
test_product=obj('test-product','PBXFileReference','explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = StarMusicTests.xctest; sourceTree = BUILT_PRODUCTS_DIR;')
app_group=obj('app-group','PBXGroup',f'children = {refs(source_ids+[asset,plist,privacy,model_file,launch_file,entitlements]+notice_ids)}; path = StarMusic; sourceTree = "<group>";')
test_group=obj('test-group','PBXGroup',f'children = {refs([test_file])}; path = StarMusicTests; sourceTree = "<group>";')
ui_file=obj('uifile','PBXFileReference','lastKnownFileType = sourcecode.swift; path = InteractionTests.swift; sourceTree = "<group>";')
ui_build=obj('uibuild','PBXBuildFile',f'fileRef = {ui_file};')
ui_product=obj('ui-product','PBXFileReference','explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = StarMusicUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR;')
ui_group=obj('ui-group','PBXGroup',f'children = {refs([ui_file])}; path = StarMusicUITests; sourceTree = "<group>";')
products=obj('products' ,'PBXGroup',f'children = {refs([app_product,test_product,ui_product])}; name = Products; sourceTree = "<group>";')
main=obj('main','PBXGroup',f'children = {refs([app_group,test_group,ui_group,products])}; sourceTree = "<group>";')
app_sources=obj('app-sources','PBXSourcesBuildPhase',f'buildActionMask = 2147483647; files = {refs(build_ids)}; runOnlyForDeploymentPostprocessing = 0;')
test_sources=obj('test-sources','PBXSourcesBuildPhase',f'buildActionMask = 2147483647; files = {refs([test_build])}; runOnlyForDeploymentPostprocessing = 0;')
app_resources=obj('app-resources','PBXResourcesBuildPhase',f'buildActionMask = 2147483647; files = {refs([asset_build,privacy_build,launch_build]+notice_builds)}; runOnlyForDeploymentPostprocessing = 0;')
app_frameworks=obj('app-frameworks','PBXFrameworksBuildPhase','buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;')
test_frameworks=obj('test-frameworks','PBXFrameworksBuildPhase','buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;')
proxy=obj('proxy','PBXContainerItemProxy',f'containerPortal = {ident("project")}; proxyType = 1; remoteGlobalIDString = {ident("app-target")}; remoteInfo = StarMusic;')
dependency=obj('dependency','PBXTargetDependency',f'target = {ident("app-target")}; targetProxy = {proxy};')
def configs(name,settings):
    ids=[]
    for conf in ['Debug','Release']:
        merged=dict(settings)
        if name=='project':
            merged.update({'SWIFT_OPTIMIZATION_LEVEL':'-Onone' if conf=='Debug' else '-O','DEBUG_INFORMATION_FORMAT':'dwarf' if conf=='Debug' else 'dwarf-with-dsym','ENABLE_TESTABILITY':'YES' if conf=='Debug' else 'NO'})
        body=' '.join(f'{q(k)} = {q(v)};' for k,v in merged.items())
        ids.append(obj(name+'-'+conf,'XCBuildConfiguration',f'buildSettings = {{ {body} }}; name = {conf};'))
    return obj(name+'-configs','XCConfigurationList',f'buildConfigurations = {refs(ids)}; defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
base={'SWIFT_VERSION':'5.0','IPHONEOS_DEPLOYMENT_TARGET':'17.0','SDKROOT':'iphoneos','CLANG_ENABLE_MODULES':'YES','CLANG_ENABLE_OBJC_ARC':'YES','ENABLE_USER_SCRIPT_SANDBOXING':'YES','MARKETING_VERSION':'0.6.0','CURRENT_PROJECT_VERSION':'7','CODE_SIGN_STYLE':'Automatic','DEVELOPMENT_TEAM':''}
project_configs=configs('project',base)
app_configs=configs('app',{'PRODUCT_NAME':'$(TARGET_NAME)','PRODUCT_BUNDLE_IDENTIFIER':'music.star.starmusic','INFOPLIST_FILE':'StarMusic/Info.plist','GENERATE_INFOPLIST_FILE':'NO','TARGETED_DEVICE_FAMILY':'1,2','ASSETCATALOG_COMPILER_APPICON_NAME':'AppIcon','LD_RUNPATH_SEARCH_PATHS':'$(inherited) @executable_path/Frameworks','SUPPORTED_PLATFORMS':'iphoneos iphonesimulator','CODE_SIGN_ENTITLEMENTS[sdk=iphonesimulator*]':'StarMusic/Simulator.entitlements','CODE_SIGN_IDENTITY[sdk=iphonesimulator*]':'-'})
test_configs=configs('test',{'PRODUCT_NAME':'$(TARGET_NAME)','PRODUCT_BUNDLE_IDENTIFIER':'music.star.starmusic.tests','GENERATE_INFOPLIST_FILE':'YES','TEST_HOST':'$(BUILT_PRODUCTS_DIR)/StarMusic.app/StarMusic','BUNDLE_LOADER':'$(TEST_HOST)','TARGETED_DEVICE_FAMILY':'1,2','LD_RUNPATH_SEARCH_PATHS':'$(inherited) @executable_path/Frameworks @loader_path/Frameworks'})
app=obj('app-target','PBXNativeTarget',f'buildConfigurationList = {app_configs}; buildPhases = {refs([app_sources,app_frameworks,app_resources])}; buildRules = (); dependencies = (); name = StarMusic; productName = StarMusic; productReference = {app_product}; productType = "com.apple.product-type.application";')
test=obj('test-target','PBXNativeTarget',f'buildConfigurationList = {test_configs}; buildPhases = {refs([test_sources,test_frameworks])}; buildRules = (); dependencies = {refs([dependency])}; name = StarMusicTests; productName = StarMusicTests; productReference = {test_product}; productType = "com.apple.product-type.bundle.unit-test";')
ui_sources=obj('ui-sources','PBXSourcesBuildPhase',f'buildActionMask = 2147483647; files = {refs([ui_build])}; runOnlyForDeploymentPostprocessing = 0;')
ui_frameworks=obj('ui-frameworks','PBXFrameworksBuildPhase','buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;')
ui_configs=configs('ui',{'PRODUCT_NAME':'$(TARGET_NAME)','PRODUCT_BUNDLE_IDENTIFIER':'music.star.starmusic.uitests','GENERATE_INFOPLIST_FILE':'YES','TEST_TARGET_NAME':'StarMusic','TARGETED_DEVICE_FAMILY':'1,2'})
ui=obj('ui-target','PBXNativeTarget',f'buildConfigurationList = {ui_configs}; buildPhases = {refs([ui_sources,ui_frameworks])}; buildRules = (); dependencies = {refs([dependency])}; name = StarMusicUITests; productName = StarMusicUITests; productReference = {ui_product}; productType = "com.apple.product-type.bundle.ui-testing";')
obj('project','PBXProject' ,f'attributes = {{ LastUpgradeCheck = 1600; TargetAttributes = {{ {app} = {{ CreatedOnToolsVersion = 16.0; }}; {test} = {{ CreatedOnToolsVersion = 16.0; TestTargetID = {app}; }}; }}; }}; buildConfigurationList = {project_configs}; compatibilityVersion = "Xcode 14.0"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en,Base); mainGroup = {main}; productRefGroup = {products}; projectDirPath = ""; projectRoot = ""; targets = {refs([app,test,ui])};')
text='// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n'+'\n'.join(objects)+'\n}; rootObject = '+ident('project')+'; }\n'
(project/'project.pbxproj').write_text(text)
schemes=project/'xcshareddata/xcschemes';schemes.mkdir(parents=True,exist_ok=True)
def buildable(target,name):return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target}" BuildableName="{name}" BlueprintName="{name.split(".")[0]}" ReferencedContainer="container:StarMusic.xcodeproj"/>'
app_ref=buildable(app,'StarMusic.app');test_ref=buildable(test,'StarMusicTests.xctest');ui_ref=buildable(ui,'StarMusicUITests.xctest')
scheme=f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.3">
<BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries>
<BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{app_ref}</BuildActionEntry>
<BuildActionEntry buildForTesting="YES" buildForRunning="NO" buildForProfiling="NO" buildForArchiving="NO" buildForAnalyzing="YES">{test_ref}</BuildActionEntry>
<BuildActionEntry buildForTesting="YES" buildForRunning="NO" buildForProfiling="NO" buildForArchiving="NO" buildForAnalyzing="YES">{ui_ref}</BuildActionEntry>
</BuildActionEntries></BuildAction>
<TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{test_ref}</TestableReference><TestableReference skipped="NO">{ui_ref}</TestableReference></Testables></TestAction>
<LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{app_ref}</BuildableProductRunnable></LaunchAction>
<ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{app_ref}</BuildableProductRunnable></ProfileAction>
<AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>'''
(schemes/'StarMusic.xcscheme').write_text(scheme)
print('Generated StarMusic.xcodeproj with',len(app_files),'Swift source files and shared StarMusic scheme.')
