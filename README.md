# `bashbits` $v(\frac{0}{0}$ $+\ \lim_{x\to\infty} f(x) +$ $n^{f(x)})$
> _a loose-leaf binder of my assorted scripts which I like being able to access via github._  
> ### Now all in the same place!   
  
### by [@zudsniper](https://github.com/zudsniper)  

## LINKS 
[`bashrc.zod.tf`](https://bashrc.zod.tf/)  
_a direct link to my `~/.bashrc` file<sub>(always a work in progress)</sub>_

## VERSIONING  
The versions for these are pretty asynchronous, and certainly NOT AT ALL kept track of. YMMV.  
### 💘 _`v4.0.0`_

 ### 🌐 General Versioning Convention 
I am now imposing a versioning convention explained as follows. This should be followed wherever possible.   
  
> the second line of all files must contain, eventually, a `v` or `V` followed by a valid major.minor.patch[^1] version string.  

<a href="https://zod.tf/"><img src="https://github.com/zudsniper/bashbits/assets/16076573/1f6a7bc0-daa9-401b-be05-693bf6357845" alt="second zod.tf logo" width="150rem" style="max-width: 100%;"></a>

--- 

## FILES
<sup> _(i know this is VERY out of date)_ </sup>
> ```diff
>   📁 anim_cli ✨  
> +    📄 bubbles-fs.sh   
>      📄 intro-fs.sh  
>      📄 shellwash-fs.sh   
> + 📁 builders 🔧  
> +    📄 build_py3.sh   
> +    📄 build_tsnode.sh  
> +    📄 shellwash-fs.sh  
> + 📁 helpers 🩹  
> +    📄 activenv.sh   
> +    📄 beautify_dir.sh  
> +    📄 docker_merge.sh   
> +    📄 to_gist.sh 
> + 📁 installers 💉  
> +    📄 get_dock.sh   
> +    📄 get_gh.sh  
> +    📄 get_gum.sh   
> +    📄 get_nvm.sh  
> +    📄 get_py.sh  
> + 📁 os_setup 🧫  
> +    📄 deb11_base.sh  
> +    📄 deb11_nonfree.sh  
> + 📁 pgp 🧫  
> +    📄 pgp_gen.sh  
> - 📄 beautify_dir.sh   
> - 📄 docker_merge.sh     
> - 📄 get_gum.sh   
> - 📄 get_gh.sh  
> - 📄 get_nvm.sh                     
> - 🧰 deb11_base.sh
> + 🎨.ansi_colors.sh
> + 🧬.bashrc   
> + 💭 README.md                     <-- 📍 YOU ARE HERE  
>   📄 LICENSE    
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

[![Discord](https://img.shields.io/discord/974855479975100487?label=tf2%20discord)](https://discord.gg/zodtf)  ![GitHub issue custom search](https://img.shields.io/github/issues-search?color=114444&label=issues&query=involves%3Azudsniper)  ![GitHub followers](https://img.shields.io/github/followers/zudsniper?style=social)  

> _fullstack development, server administration, web design, branding creation, musical composition & performance, video editing, and more probably_   

<a href="https://zod.tf/"><img src="https://github.com/zudsniper/bashbits/assets/16076573/1f6a7bc0-daa9-401b-be05-693bf6357845" alt="second zod.tf logo" width="150rem" style="max-width: 100%;"></a>


[^1]: Regular expression that _should_ match all valid versions: `([0-9]+(.)){2}([0-9]+){1}(\-\w+)?`