# Tips
---

### Assembly
---
```sh
mipsel-linux-gnu-as -EB -o a.o a.s
```
The `-EB` option is big endian choice.

Now you have got an ELF file,you need to link it by yourself.Before this,you can use this command to check it:

```sh
mipsel-linux-gnu-readelf -S a.o
```

You can get the section headers of it,like this:
```sh
root@Aurora:/home/code/verilog/Sirius/src/mips(master⚡) # mipsel-linux-gnu-readelf -S a.o                                  1 ↵
There are 11 section headers, starting at offset 0x184:

节头：
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        00000000 000040 000010 00  AX  0   0 16
  [ 2] .data             PROGBITS        00000000 000050 000000 00  WA  0   0 16
  [ 3] .bss              NOBITS          00000000 000050 000000 00  WA  0   0 16
  [ 4] .reginfo          MIPS_REGINFO    00000000 000050 000018 18   A  0   0  4
  [ 5] .MIPS.abiflags    MIPS_ABIFLAGS   00000000 000068 000018 18   A  0   0  8
  [ 6] .pdr              PROGBITS        00000000 000080 000000 00      0   0  4
  [ 7] .gnu.attributes   GNU_ATTRIBUTES  00000000 000080 000010 00      0   0  1
  [ 8] .symtab           SYMTAB          00000000 000090 000090 10      9   8  4
  [ 9] .strtab           STRTAB          00000000 000120 000009 00      0   0  1
  [10] .shstrtab         STRTAB          00000000 000129 000059 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  p (processor specific)
root@Aurora:/home/code/verilog/Sirius/src/mips(master⚡) #
```

### Link
---
The next step is link:
```sh
mipsel-linux-gnu-ld -EB -o a.om a.o
```
Now you have got a executable file.You can use readelf to check it:
```sh
root@Aurora:/home/code/verilog/Sirius/src/mips(master⚡) # mipsel-linux-gnu-readelf -h inst_rom.om
ELF 头：
  Magic：  7f 45 4c 46 01 02 01 00 00 00 00 00 00 00 00 00
  类别:                              ELF32
  数据:                              2 补码，大端序 (big endian)        # Make sure that it is big endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI 版本:                          0
  类型:                              EXEC (可执行文件)
  系统架构:                          MIPS R3000
  版本:                              0x1
  入口点地址：              0x4000d0
  程序头起点：              52 (bytes into file)                        # New data from a.o
  Start of section headers:          580 (bytes into file)
  标志：             0x1000, o32, mips1
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         3
  Size of section headers:           40 (bytes)
  Number of section headers:         8
  Section header string table index: 7
root@Aurora:/home/code/verilog/Sirius/src/mips(master⚡) #
```
The program header is newly added.We can use the following command to read the Program header:

```sh
mipsel-linux-gnu-readelf -l a.o
```

You can get this:

```sh
root@Aurora:/home/code/verilog/Sirius/src/mips(master⚡) # mipsel-linux-gnu-readelf -l inst_rom.om

Elf 文件类型为 EXEC (可执行文件)
Entry point 0x4000d0
There are 3 program headers, starting at offset 52

程序头：
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  ABIFLAGS       0x000098 0x00400098 0x00400098 0x00018 0x00018 R   0x8
  REGINFO        0x0000b0 0x004000b0 0x004000b0 0x00018 0x00018 R   0x4
  LOAD           0x000000 0x00400000 0x00400000 0x000e0 0x000e0 R E 0x10000

 Section to Segment mapping:
  段节...
   00     .MIPS.abiflags
   01     .reginfo
   02     .MIPS.abiflags .reginfo .text
root@Aurora:/home/code/verilog/Sirius/src/mips(master⚡) #
```

### Translate 
---
The a.om is an ELF file,which is quite different from ROM init file like "inst_rom.data".So we need to translate the format.We can use the "objdump" to translate into "binary data" file.In fact, we need to do it manually...

```sh
mipsel-linux-gnu-objdump -D a.om
```
We can use this command to get its disassembly code:
```sh
root@Aurora:/home/code/verilog/Sirius/src/mips(master⚡) # mipsel-linux-gnu-objdump -D inst_rom.om                                                                      1 ↵

inst_rom.om：     文件格式 elf32-tradbigmips


Disassembly of section .MIPS.abiflags:

00400098 <.MIPS.abiflags>:
  400098:       00000100        sll     zero,zero,0x4
  40009c:       01010001        0x1010001
        ...

Disassembly of section .reginfo:

004000b0 <.reginfo>:
  4000b0:       0000001e        0x1e
        ...
  4000c4:       004180d0        0x4180d0

Disassembly of section .text:

004000d0 <__start>:                                                 # Look! We can see the instructions!
  4000d0:       34011100        li      at,0x1100
  4000d4:       34020020        li      v0,0x20
  4000d8:       3403ff00        li      v1,0xff00
  4000dc:       3404ffff        li      a0,0xffff

Disassembly of section .gnu.attributes:

00000000 <.gnu.attributes>:
   0:   41000000        bc0f    4 <__start-0x4000cc>
   4:   0f676e75        jal     d9db9d4 <_gp+0xd5c3904>
   8:   00010000        sll     zero,at,0x0
   c:   00070401        0x70401
```

Now we need to select the instructions manually:

```sh
mipsel-linux-gnu-objdump -D inst_rom.om | sed '/__start/, /^$/!d' | sed -n '1,/^$/p' | sed  '/start/d | awk -F " " '{print $2}'
```

Like this:
```sh
root@Aurora:/home/code/verilog/Sirius/src/mips(master⚡) # mipsel-linux-gnu-objdump -D inst_rom.om | sed '/__start/, /^$/!d' | sed -n '1,/^$/p' | sed  '/start/d'
  4000d0:       34011100        li      at,0x1100
  4000d4:       34020020        li      v0,0x20
  4000d8:       3403ff00        li      v1,0xff00
  4000dc:       3404ffff        li      a0,0xffff

root@Aurora:/home/code/verilog/Sirius/src/mips(master○) # mipsel-linux-gnu-objdump -D inst_rom.om | sed '/__start/, /^$/!d' | sed -n '1,/^$/p' | sed  '/start/d' | awk -F " " '{print $2}'
34011100
34020020
3403ff00
3404ffff

root@Aurora:/home/code/verilog/Sirius/src/mips(master○) # 

```

Congratulations! You have got the instructions!

### Finally
---
We can write a makefile to implement automation:

```makefile
ifndef CROSS_COMPILE
        CROSS_COMPILE = mipsel-linux-gnu-
endif

CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJDUMP = $(CROSS_COMPILE)objdump
TRANSLATE = $(OBJDUMP) -D $(OM_FILE) | sed '/__start/, /^$$/!d' | sed -n '1,/^$$/p' | sed  '/start/d' | awk -F " " '{print $$2}'

OBJECTS = inst_rom.o
OM_FILE = inst_rom.om

export CROSS_COMPILE

all: inst_rom.data

%.o: %.s
        $(CC) -EB -o $@ $<

inst_rom.om: $(OBJECTS)
        $(LD) -EB -o inst_rom.om inst_rom.o

inst_rom.data: inst_rom.om
        $(TRANSLATE) > $@

clean:
        rm -f *.o *.om
```

