# mega.syno
Make possible to use mega.nz`s megasync on Synology with Docker

`sudo docker pull johnshine/mega.syno:latest`

`sudo docker run -d -p 5901:5901 -p 6080:6080 -v /path/to/sync/folder:/home/mega/MEGA johnshine/mega.syno:latest`

then connect vnc desktop with vnc client at port 5901

## Screenshots
<img src="https://raw.githubusercontent.com/john-shine/mega.syno/master/screenshots/1.png" alt="screenshot1" width="300" />
<img src="https://raw.githubusercontent.com/john-shine/mega.syno/master/screenshots/2.png" alt="screenshot2" width="300" />

## Synology tutorial
updating...

## History

## v1.2
+ Write a Qt program to simulate tray
+ update megasync to 4.2.5

### v1.1
+ Thanks for [salvq](https://github.com/salvq)\`s information. To enable one way sync, set sync folder read only to Container as following:
  `sudo docker run -d -p 5901:5901 johnshine/mega.syno:latest-v /path/to/host/sync/folder:/megaclient-folders/:ro`
+ update megasync to 3.7.1
