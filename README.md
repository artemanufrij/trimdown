<div>
  <h1 align="center">TrimDown</h1>
  <h3 align="center"><img src="data/icons/64/com.github.artemanufrij.trimdown.svg"/><br>A simple, feature rich, writing app for writing Novels, Short stories, Scripts and Articles.</h3>
  <p align="center">Designed for <a href="https://elementary.io">elementary OS</a></p>
</div>

### Donate
<a href="https://www.paypal.me/ArtemAnufrij">PayPal</a> | <a href="https://liberapay.com/Artem/donate">LiberaPay</a> | <a href="https://www.patreon.com/ArtemAnufrij">Patreon</a>

## Install from Github.
As first you need some packages
```
sudo apt install git meson libgranite-dev libgtksourceview-3.0-dev
```
Clone repository and change directory
```
git clone https://github.com/artemanufrij/trimdown.git
cd trimdown
```
Compile, install and start Find File Conflicts on your system
```
meson build --prefix=/usr
cd build
sudo ninja install
com.github.artemanufrij.trimdown
