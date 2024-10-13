# OPEN-Index-File-Downloader
Downloads files from an open directory, including subdirectories, to a local machine using wget and preserves the directory structure.


This bash script was created since I could not download all files recusrively from `https://wordlists-cdn.assetnote.io/data/` while I was working on the book `Hacking APIs` from Corey J. Ball.
One of the commands was `wget -r --no-parent -R "index.html*" https://wordlists-cdn.assetnote.io/data/ -nH` to download all wordlists locally. Did did not work for me, so I was trying to craft a command to do the same but I failed in that.

Therefore I tried to create a bash script to do the same. See screenshots.

This screenshots shows that the files are being download
![image](https://github.com/user-attachments/assets/2ea800fc-672b-4167-87fa-1c2b31c72f81)
This sceenshots shows that the files are download in the correct subfolders as well.
![image](https://github.com/user-attachments/assets/3b8ed8ea-e088-47c6-ae10-b376317c9483)


### Usage
Download from the default URL.
```bash
./OIFD.sh
```
Need some help?
```bash
./OIFD.sh --help
```
Download from another OPEN Index website?
```bash
./OIFD.sh --url http://anotherwebsite.example.com/data
```

### **Disclaimer**

**USE AT YOUR OWN RISK**

The author of this bash script is not responsible for any damage or actions resulting from the execution of this script. By running this script, you acknowledge that you are fully responsible for any consequences that may arise from its use.

This script was created for educational purposes only, and it is your responsibility to ensure that you understand the implications of running this script on your system. You should carefully review the script's code and functionality before executing it.

By executing this script, you agree to hold the author harmless for any damages or losses that may occur as a result of its use. You also acknowledge that you have the necessary permissions and authority to execute this script on your system.
