# `bashbits` 🧰 
> _a loose-leaf binder of my assorted scripts which I like being able to access via github._  
> ### Now all in the same place!   
  
### by [@zudsniper](https://github.com/zudsniper)  

## LINKS 
- 🔗[`bashrc.zod.tf`](https://bashrc.zod.tf/)  
_a direct link to my `~/.bashrc` file<sub>(always a work in progress)</sub>_
- 🔗[`gh.zod.tf/bashbits/raw/master/*`](https://gh.zod.tf/bashbits/raw/master/.bashrc)  
_shorthand to link directly to raw text of any file within this repo._

## VERSIONING  
The versions for these are pretty asynchronous, and certainly NOT AT ALL kept track of. YMMV.  
### 💘 _`v4.0.1`_
> #### `changelog`
> `v4.0.1` **MacOS & Assorted Scripts**
> - Added `.zshrc` for MacOS `Ventura 13.5.1` (Apple Silicon)<sub>though this was originally developed on Catalina (10.15.7), so...</sub>
> - Added `gitget.sh` to get obtain and install a script from a github url, or author and repo combination using the releases of that repository. ***UNTESTED***, definitely doesn't work.
> - Updates to `.ansi_colors.sh` to add shorthand color variable exports for very common colors `RED`, `GREEN`, `YELLOW`, `BLUE`, and `NC` as a shortcut for `RESET`. 
> - Updated `README.md` to reflect changes, even the file structure diff thing _wow_.
> 
> ---
> `v4.0.0` **Some Housekeeping**
> - `.bashrc` adding planning and some actual additions
> - `.ansi_colors.sh` updating the file to contain actually all the currently referenced colors within... itself. Hopefully.
> - `README.md` Updating
> - Updating the version definition convention which I am now imposing on all scripts I write for standardization purposes
> - Deleted / moved old scripts such as the original locations of `get_nvm.sh`.
> - Moved all scripts (for the most part) into descriptive folders
> - more probably
> ---

 ### 🌐 General Versioning Convention 
I am now imposing a versioning convention explained as follows. This should be followed wherever possible.   
  
> the second line of all files must contain, eventually, a `v` or `V` followed by a valid major.minor.patch[^1] version string.  

--- 

## FILES

> ```diff
>  📁 anim_cli ✨  
>     📄 bubbles-fs.sh   
>     📄 intro-fs.sh  
>     📄 shellwash-fs.sh   
>  📁 builders 🔧  
>     📄 build_py3.sh   
>     📄 build_tsnode.sh  
>     📄 shellwash-fs.sh  
>  📁 helpers 🩹  
>     📄 activenv.sh   
>     📄 beautify_dir.sh  
>     📄 docker_merge.sh   
>     📄 to_gist.sh 
>  📁 installers 💉  
>     📄 get_dock.sh   
>     📄 get_gh.sh  
>     📄 get_gum.sh   
>     📄 get_nvm.sh  
>     📄 get_py.sh  
>  📁 os_setup 🧫  
>     📄 deb11_base.sh  
>     📄 deb11_nonfree.sh  
>  📁 pgp 🧫  
>     📄 pgp_gen.sh
> + 🧲 gitget.sh
> + 🎨.ansi_colors.sh
> + 🧫.zshrc  
> + 🧬.bashrc
> + 💭 README.md                     <-- 📍 YOU ARE HERE  
>   📄 LICENSE    
> + 💾 .gitignore
> ```

## ONE-LINERS  
_Here are single-line, single-execution, daisychains of_ `bash` _to accomplish something or other._   

<br />  

Install `deb11_base.sh` on a clean install of debian 11.  
> ❗❗ **MUST BE RUN AS ROOT** ❗❗  
  
```sh
curl -sL https://raw.githubusercontent.com/zudsniper/bashbits/master/deb11_base.sh -o ~/build.sh; chmod ugo+X ~/build.sh; ./build.sh -r me -pw password -k "ssh-rsa xx"; source ~/.bashrc; settitle "$(hostname -f)";
```

## LICENSE
This code is all **MIT Licensed**.  
📄 [`LICENSE`](/LICENSE)  

<hr>

<i><code>zod.tf</code></i> 

[![Discord](https://img.shields.io/discord/974855479975100487?label=tf2%20discord)](https://discord.zod.tf)  ![GitHub issue custom search](https://img.shields.io/github/issues-search?color=E771F0&label=issues&query=involves%3Azudsniper)  ![GitHub followers](https://img.shields.io/github/followers/zudsniper?style=social)  

> _fullstack development, server administration, web design, branding creation, musical composition & performance, video editing, and more probably_   

<a href="https://zod.tf/"><img src="https://github.com/zudsniper/bashbits/assets/16076573/1f6a7bc0-daa9-401b-be05-693bf6357845" alt="second zod.tf logo" width="120px" style="max-width: 100%;"></a>


[^1]: Regular expression that _should_ match all valid versions: `([0-9]+(.)){2}([0-9]+){1}(\-\w+)?`
