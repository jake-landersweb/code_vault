# Unix Setup

> This is a guide used to help some of my workshop students get up to speed using the command line.

What is Unix? I dont know, but it is a cool word that has something to do with a terminal environment. The technical definition is different from my abstract definition. To me, Unix means you type `cd` to "c"hange "d"irectories instead of `dir`. If you are on mac, congratuations, you already have a unix terminal installed on your computer. If you are on windows, I am sorry, you are going to have to bang your head against a wall in order to get the ubunutu app working. I tried to outline some instructions in `windows_setup.md` to help get that process moving, but those directions most likely will not work and we will have to meet 1-1 to get your computer working properly.

## What is a Terminal?

If you have ever seen a movie that has a hacking component, then you may be familar with green lines of text on a black background attempting to symbolize a computer. This is kind of like that, except more practical. A terminal can be thought of as a different way of interacting with your computer. You are used to using your mouse to click on visual elements. Double clicking on folders and files to open them, dragging windows around, and clicking arrows to go back in a file tree.

We are not going to be doing any of that here. The terminal is a keyboard based way of navigating around your computer. I am not going to sugar coat this, getting up to speed using the terminal is going to be difficult. You are going to get frustrated and feel like you have no idea what is going on throughout the semester. It takes practice, but I am confident you can get the hang of it.

Why are we using the terminal? the programs required to accomplish genomics research only work using the command line. These programs are meant to get serious computational work done, not look pretty and feel good to use. There are no graphical windows for them. You only have an online user manual and a terminal help screen to use them. Working in this environment requires you to think thoroughly about what exactly you are doing and why you are doing things. Most of the time, your first approach will not work. Nor will your 5th. But if this stuff was easy, everyone would do it. 

## First Steps

- [Create a Directory](#create-a-directory)
- [Create a File](#create-a-file)
- [Execute a File](#execute-a-file)

### Create a Directory

Now that all of that is out of the way, lets move onto getting familar with the environment

On mac, simply open the terminal. On windows, open the ubuntu app and run the command `cd /home/{username}`.

This is your home directory. Type the command `ls` to 'list' all of the files and folders present in this folder. On mac, you might see some familar things. Documents, Downloads, Applications, Desktop. These all are the same location as you might see in finder. In Windows, your home directory will be empty.

Create a new folder named 'code' with the `mkdir` command. `mkdir code`. This will create a new folder named 'code'.

> From now on, assume that directory and folder mean the exact same thing

### Create a File

Navigate into that folder with `cd code/`. Create a new file using the `touch` command. `touch hello_world.sh`. The `.sh` signifies a file type. You may have seen .docx, or .pdf. Those are file formats that tell your computer what type of file this is. A .sh file is a 'shell' file. Open the shell file with vim. `vi hello_world.sh`. This will open a primitive text editor that only supports navigation with the keyboard.

To exit vim, you can run 3 different commands based on what you want to do. If you have not edited the file, you can simply close vim with hitting `esc`, then typing `:q` and clicking enter. If you have edited the file you have 2 other options. The first is to save the file and quit: `:wq`. The second, is to close without saving: `:q!`. 

Inside of vim, you need to specify whether you want to type text by entering insert mode. Click the `i` key, Now, you can type. Best practices for shell files is to denote what shell processor you want to use to run the file. in the first line, type `#!/bin/sh`. Click enter twice for a new line, and type `echo hello world`.

Your file should look like the following:

```shell
#!/bin/sh

echo hello world
```

Hit escape, and type `:wq` and enter to save the file and quit.

### Execute a File

Now, on the command line we can run this file with two commands. Either `bash` or `sh`. Both mac and windows will have both installed, and which one you use is largly down to preference, but I am partial to sh so that is the one we will use.

Run the file using sh with the following command:

```shell {1}
sh ./hello_world.sh

$ hello world
```

You should see hello world print to your screen. Congratulations, you are now a software developer.

### Next steps

Play around with the concepts you have learned here. As an added exercise, use this document and Google to get a shell script that prints the numbers 1-10 on a new line. A hint is in the following code snipet:

```shell
for i in {..}
do
    $i
done
```

Some Google key words that might help you find a potential solution:
- Loop
- Bash
- Shell
- Iterate
- Range of numbers

Save this in a file named `loop.sh`.

**Expected output:**

```shell
0
1
2
3
4
5
6
7
8
9
10
```