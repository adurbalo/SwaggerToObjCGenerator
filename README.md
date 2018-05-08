# SwaggerToObjCGenerator
Objective C code genegator for Swagger

### How to get started
- In your project's root folder create directory with name **SwaggerCodeGenerator**
- Download **SwaggerToObjCGenerator** project
- Unzip and copy **SwaggerToObjCGenerator** file and **Resource** directory into created **SwaggerCodeGenerator** directory
- Create **SwagerSources** directory where you'll generate swagger classes

![alt text](https://preview.ibb.co/fo9eZS/1.png)

- Select Project -> Editor -> Add New Target -> Cross-platform -> Aggregate

![alt text](https://preview.ibb.co/gGf6g7/2.png)

- Name it **SwaggerCodeGenerator** and press Finish
- Select **SwaggerCodeGenerator** -> Build Phases -> New Run Script Phase

![alt text](https://preview.ibb.co/icKhM7/3.png)

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
![alt text](https://preview.ibb.co/kS0iTn/4.png)

- Select **SwaggerCodeGenerator** scheme and press Run
- Check your **SwagerSources** directory and add new files to project

![alt text](https://preview.ibb.co/jOoL8n/5.png)

- Create subclass for your **<YOUR_PREFIX>AbstractServerAPI** and implement **ServerAPIInheritor** protocol

![alt text](https://preview.ibb.co/kAVuZS/6.png)

- Have a fun

