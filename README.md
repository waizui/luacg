# luacg


## Description

![preview](./preview.png)

luacg is a project implements computer graphics algorithms in pure lua.

you can learn computer graphics by reading the source code and making changes.

more algorithms will be added in the future.

## Usage

To use luacg, you need to install lua interpreter in your computer.

It can be downloaded [here](https://sourceforge.net/projects/luabinaries/files/5.3.6/Tools%20Executables/)

To execute luacg, cd to the folder of this project.

and execute following command. The "path_to_the_lua53" should be abosolute path to the interpreter you have
downloaded, which is named lua53 (lua version 5.3).

```bash
path_to_the_lua53 ./scene.lua
```

The execution results will be placed in the folder of this project.

## List

### 1. rasterisation and  barycentric coordinates

![1](./pic/rasterize_preview.png)


### 2. naive path tracing

![2](./pic/raycast_preview.png)

## References

[Appied Computer Graphics by Prof. Nobuyuki Umetani](https://github.com/ACG-2024S/acg)

[pbr-book](https://pbr-book.org/4ed/contents)

[lua-pngencoder](https://github.com/wyozi/lua-pngencoder)
