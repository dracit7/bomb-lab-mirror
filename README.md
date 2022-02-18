# bomb lab

> A mirror of the simplified IPADS bomb lab.

拆弹实验用到的bomb 二进制文件是基于AArch64 架构的，我们需要
安装qemu-user 包来运行bomb 文件。在实验环境搭建（链接）的基础上运
行命令：

```sh
sudo apt update && sudo apt install qemu-user
```

## 简介
在Bomb lab 中，你需要通过阅读汇编代码以及使用调试工具来拆除一
个二进制炸弹程序。本实验分为两个部分：第一部分介绍拆弹实验的基本知
识，包括ARM 汇编语言、QEMU 模拟器、GDB 调试器的使用；第二部分
需要分析炸弹程序，推测正确的输入来使得炸弹程序能正常退出。

## 基本知识

本部分旨在熟悉ARM 汇编语言，以及使用QEMU 和QEMU/GDB
调试。

## 熟悉AArch64 汇编
AArch64 是ARMv8 ISA 的64 位执行状态。《ARM 指令集参考指
南》（链接）是一个帮助入门ARM 语法的手册。在ChCore 实验中，只需
要在提示下可以理解一些关键汇编和编写简单的汇编代码即可。

## 使用QEMU 运行炸弹程序
在之前的步骤中我们生成了bomb二进制文件，但该文件只能运行在基
于AArch64 的Linux 中。通过QEMU，我们可以在其他架构上模拟运行。
同时，QEMU 可以结合GDB 进行调试（如打印输出、单步调试等）。

小知识: QEMU 不仅可以模拟运行用户态程序，也可以模拟运行在
内核态的操作系统。在前一种模式下，QEMU 会模拟运行用户态的汇
编代码，同时将系统调用等翻译为对宿主机的调用。在后一种模式下，
QEMU 将在虚拟硬件上模拟一整套计算机启动的过程。
在bomb-lab目录下，输入以下命令可以在QEMU 中运行炸弹程序：
os-bomb$ make qemu
炸弹程序的标准输出将会显示在QEMU 中：

```sh
Type in your defuse password:
```

## QEMU 与GDB
在实验中，由于需要在x86-64 平台上使用GDB 来调试AArch64 代
码，因此使用gdb-multiarch代替了普通的gdb。使用GDB 调试的原理是，
QEMU 可以启动一个GDB 远程目标（remote target）（使用-s或-S参数
启动），QEMU 会在真正执行镜像中的指令前等待GDB 客户端的连接。开
启远程目标之后，可以开启GDB 进行调试，它会在某个端口上进行监听。
我们提供了一个GDB 脚本.gdbinit来初始化GDB，并且设置了其监听端
口为QEMU 的默认端口（tcp::1234）。
打开两个终端，在bomb-lab目录下，输入make qemu-gdb和make gdb命
令可以分别打开带有GDB 调试的QEMU 以及GDB，在GDB 中将会看
到如下的输出：
```sh
$ make gdb
...
0x0000000000400540 in ?? ()
add symbol table from file "bomb"
(y or n) y
Reading symbols from bomb...
(gdb)
```

## 二进制炸弹的拆除
我们在实验中提供了一个二进制炸弹程序bomb以及它的部分源码bomb.c。
在bomb.c 中，你可以看到一共有6 个phase。对每个phase，bomb程序将
从标准中输入中读取一行用户输入作为这一阶段的拆弹密码。若这一密码
错误，炸弹程序将异常退出。我们将在该文档中对phase_0 进行示例性的
拆除，你的任务是通过GDB 以及阅读汇编代码，判断怎样的输入可以使得
炸弹程序正常通过后面5 个phase。以下是一次失败尝试的例子：
```sh
$ make qemu
qemu -aarch64 bomb
Type in your defuse password:
wrong password
BOOM!!!
```

## 提示
你需要学习gdb、objdump的使用来查看炸弹程序对应的汇编，并通过
断点等方法来查看炸弹运行时的状态（寄存器、内存的值等）。以下是使
用gdb来查看炸弹运行状态的例子。在这个例子中，我们在main函数的开
头打了一个断点，通过continue让程序运行直至遇到我们设置的断点，使
用info查看了寄存器中的值，最终通过x查看了x0寄存器中的地址指向的字
符串的内容。

```sh
(gdb) break main
Breakpoint 1 at 0x4005f4
(gdb) continue
Continuing.
Breakpoint 1, 0x00000000004005f4 in main ()
(gdb) disassemble
Dump of assembler code for function main:
0x00000000004005e4 <+0>: stp x29 , x30 , [sp, # -16]!
0x00000000004005e8 <+4>: mov x29 , sp
0x00000000004005ec <+8>: adrp x0, 0x45d000 <
free_modules_db+56>
0x00000000004005f0 <+12>: add x0, x0, #0x848
=> 0x00000000004005f4 <+16>: bl 0x407a40 <puts >
0x00000000004005f8 <+20>: bl 0x400a3c <read_line >
0x00000000004005fc <+24>: bl 0x400678 <phase_1 >
0x0000000000400600 <+28>: bl 0x40064c <phase_defused >
0x0000000000400604 <+32>: bl 0x400a3c <read_line >
0x0000000000400608 <+36>: bl 0x4006a0 <phase_2 >
0x000000000040060c <+40>: bl 0x40064c <phase_defused >
0x0000000000400610 <+44>: bl 0x400a3c <read_line >
0x0000000000400614 <+48>: bl 0x400714 <phase_3 >
0x0000000000400618 <+52>: bl 0x40064c <phase_defused >
0x000000000040061c <+56>: bl 0x400a3c <read_line >
0x0000000000400620 <+60>: bl 0x400910 <phase_4 >
0x0000000000400624 <+64>: bl 0x40064c <phase_defused >
0x0000000000400628 <+68>: bl 0x400a3c <read_line >
0x000000000040062c <+72>: bl 0x4009ec <phase_5 >
0x0000000000400630 <+76>: bl 0x40064c <phase_defused >
0x0000000000400634 <+80>: adrp x0, 0x45d000 <
free_modules_db+56>
0x0000000000400638 <+84>: add x0, x0, #0x868
0x000000000040063c <+88>: bl 0x407a40 <puts >
0x0000000000400640 <+92>: mov w0, #0x0
// #0
0x0000000000400644 <+96>: ldp x29 , x30 , [sp], #16
0x0000000000400648 <+100>: ret
End of assembler dump.
(gdb) info registers x0
x0 0x45d848 4577352
(gdb) x /s 0x45d848
0x45d848: "Type in your defuse password:"
```

## 文件重定向
在破解后续阶段时，为了避免每次都需要输入先前阶段的拆弹密码，你
可以通过重定向的方式来让炸弹程序读取文件中的密码：

```sh
$ make qemu < ans.txt
qemu -aarch64 bomb
Type in your defuse password:
5 phases to go
4 phases to go
3 phases to go
2 phases to go
1 phases to go
0 phases to go
Congrats! You have defused all phases!
```

在这个例子中，我们将每一阶段的密码逐行保存在ans.txt中。若这些密码
完全正确，你将看到上述拆弹成功的提示。在检查实验结果的时候，助教也
会使用重定向ans.txt 文件的方式进行检查。请确保实验提交时，ans.txt 文
件中保存答案，并能够在本地以重定向的方式拆除你能够拆除的phase 数
量。

## phase_0 示例
在使用make gdb 的终端中查看phase_0 的汇编代码

```sh
(gdb) disas phase_0
Dump of assembler code for function phase_0:
0x0000000000400724 <+0>: stp x29 , x30 , [sp, # -16]!
0x0000000000400728 <+4>: mov x29 , sp
0x000000000040072c <+8>: bl 0x400bd0 <read_int >
0x0000000000400730 <+12>: adrp x1, 0x49d000
0x0000000000400734 <+16>: ldr w1, [x1, #76]
0x0000000000400738 <+20>: cmp w1, w0
0x000000000040073c <+24>: b.ne 0x400748 <phase_0+36> //
b.any
0x0000000000400740 <+28>: ldp x29 , x30 , [sp], #16
0x0000000000400744 <+32>: ret
0x0000000000400748 <+36>: bl 0x400aec <explode >
0x000000000040074c <+40>: b 0x400740 <phase_0+28>
End of assembler dump.
```

为了避免控制流运行到0x400748 后跳转到explode 函数，我们应该
在0x400738 的cmp 命令中得到一个equal 的结果，于是0x400738 命令
处的w0 应该等于w1。我们向上寻找w0 的值，发现在0x40072c 中调用
了read_int 函数，而根据ARM 文档函数会将返回值保存在w0 寄存器上，
因此我们可以推断w0 寄存器上面的值是我们输入的值。而根据0x400730-
0x400734 这两行汇编代码，w1 的值将是地址为0x49d000+0x4c 上的值。于
是我们可以通过命令x 进行查看内存地址上的值：

```sh
(gdb) x /d 0x49d04c
0x49d04c <phase0_ans >: 2021
```

于是我们可以知道对于phase_0 我们应该输入2021。于是在make gdb
的终端输入c 继续运行bomb 程序，在make qemu-gdb 的终端中输入2021。

```sh
Type in your defuse password!
2021
5 phases to go
```

现在，轮到你了！
