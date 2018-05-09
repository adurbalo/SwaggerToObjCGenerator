# SwaggerToObjCGenerator
Objective C code genegator for Swagger

### How to get started
- In your project's root folder create directory with name **SwaggerCodeGenerator**
- Download **SwaggerToObjCGenerator** project
- Unzip and copy **SwaggerToObjCGenerator** file and **Resource** directory into created **SwaggerCodeGenerator** directory
- Create **SwagerSources** directory where you'll generate swagger classes

<img src="https://i.imgur.com/K1jaTfT.png" border="0">

- Select Project -> Editor -> Add New Target -> Cross-platform -> Aggregate

<img src="https://i.imgur.com/WdMfdx2.png" border="0">

- Name it **SwaggerCodeGenerator** and press Finish
- Select **SwaggerCodeGenerator** -> Build Phases -> New Run Script Phase

<img src="https://i.imgur.com/ivaFdhd.png" border="0">

- Write bash script and provided needed parameters
  - **-destinationPath** path where generator should place files. 
  - **-prefix** prefix for files. 
  - **-jsonPath** local path json file. 
  - **-jsonURL** json file URL.

For example
```
path="${SRCROOT}/SwaggerCodeGenerator/"
destinationPath="$path/SwagerSources"
cd $path
./SwaggerToObjCGenerator -prefix "PFX" -jsonPath "$path/swager_uber.json" -destinationPath "$destinationPath"
```

<img src="https://i.imgur.com/LVmN2X7.png" border="0">

- Select **SwaggerCodeGenerator** scheme and press Run
- Check your **SwagerSources** directory and add new files to project

<img src="https://i.imgur.com/dC4FLdS.png" border="0">

- Create subclass for your **<YOUR_PREFIX>AbstractServerAPI** and implement **ServerAPIInheritor** protocol

<img src="https://i.imgur.com/isNusED.png" border="0">

- Have a fun

