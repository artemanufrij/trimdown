<div>
  <h1 align="center">TrimDown</h1>
  <h3 align="center"><img src="data/icons/64/com.github.artemanufrij.trimdown.svg"/><br>A simple, feature rich, writing app for writing Novels, Short stories, Scripts and Articles.</h3>
  <p align="center">Designed for <a href="https://elementary.io">elementary OS</a></p>
</div>

## Install from Github.

As first you need some packages
```
sudo apt install git meson
```

Clone repository and change directory
```
git clone https://github.com/artemanufrij/trimdown.git
cd trimdown
```

Create **build** folder, and compile the source code
```
meson build --prefix=/usr
cd build
ninja
```

Install and start TrimDown on your system
```
sudo ninja install
com.github.artemanufrij.trimdown
```
