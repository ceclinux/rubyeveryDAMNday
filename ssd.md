% All you should know about SSD
% 沈若辰
% Sept. 28, 2018

A solid-state drive (SSD) is a solid-state storage device that uses integrated circuit assemblies as memory to store data persistently. It is also sometimes called solid-state disk,[1] although SSDs do not have physical disks. SSDs may use traditional hard disk drive (HDD) form-factors and protocols such as SATA and SAS, greatly simplfying usage of SSDs in computers.[2] Following the initial acceptance of SSDs with HDD interfaces, new form factors such as the M.2 form factor, and new I/O protocols such as NVM Express have been developed to address specific requirements of the Flash memory technology used in SSDs.

------------------------

-----------------------

## 眼花缭乱的名词

SATA 2, SATA 3, M.2, PCI-E, NVME, AHCI, 4K Alignment, 2280, trim, B Key, M Key, SLC, TLC, MLC?

![黑人问号](black.jpg)


-----------------------

## 传统机械硬盘

![2.5寸机械硬盘](simple-hdd.jpg)

-----------------------

## 传统SSD

![2.5寸SSD](simple-ssd.jpg)

-----------------------

## BM Key

![B key and M Key](bmkey.png)

左边是支持“B key”的插槽，短的一段在左边，采用6pin设计，当接口连带“B key”一并使用时候，即为Socket 2接口，走SATA或PCI-E X2通道；

另一种是支持“M key”的插槽，短的一段在右边，采用5pin设计，当接口连带“M key”一并使用时候，走的是PCI-E X4通道，即为Socket 3接口。

-----------------------



![hdd结构](ssd-archi.gif)

-----------------------

Due to the extremely close spacing between the heads and the disk surface, HDDs are vulnerable to being damaged by a head crash – a failure of the disk in which the head scrapes across the platter surface, often grinding away the thin magnetic film and causing data loss. Head crashes can be caused by electronic failure, a sudden power failure, physical shock, contamination of the drive's internal enclosure, wear and tear, corrosion, or poorly manufactured platters and heads.

-----------------------

PCI Express (Peripheral Component Interconnect Express), officially abbreviated as PCIe or PCI-e,[1] is a high-speed serial computer expansion bus standard, designed to replace the older PCI, PCI-X and AGP bus standards. PCIe has numerous improvements over the older standards, including higher maximum system bus throughput, lower I/O pin count and smaller physical footprint, better performance scaling for bus devices, a more detailed error detection and reporting mechanism (Advanced Error Reporting, AER[2]), and native hot-swap functionality. More recent revisions of the PCIe standard provide hardware support for I/O virtualization. 


--------------------------

有三种逻辑设备接口和M.2存储设备接口命令集的选项可用，这可根据M.2存储设备的类型和操作系统的支持性选用：[1]:14[5][8]

传统SATA
    用于SATA SSD，以及通过M.2连接器分拆出的AHCI驱动程序和旧式SATA 3.0 (6 Gbit/s)端口。

使用AHCI的PCI Express
    用于PCI Express SSD和通过AHCI驱动程序和PCI Express通道提供的接口，使用AHCI访问PCI Express SSD，利用广泛的SATA支持在操作系统层面以提供非最佳性能的向下兼容。开发AHCI的时候, 系统的主机总线适配器 (HBA)的用途是将CPU/内存子系统通过一个相比慢得多的基于旋转磁介质的存储子系统相连，正因如此，AHCI在用于SSD设备时有一些固有的低性能问题，因为其行为更类似DRAM而非旋转介质。

使用NVMe的PCI Express
    用于PCI Express SSD和通过NVMe驱动程序和PCI Express通道提供的接口，作为一个高性能并可扩展的主机连接器接口设计，尤其是专门为PCI Express SSD的接口而优化。NVMe已全新设计，为PCI Express SSD提供低延迟和并行性，助益现代CPU、平台和应用程序的并行性。在高层次水平，NVMe相比AHCI的主要优势是NVMe能充分、并行地利用主机的硬件和软件，它的设计优势包括更少的数据传输层级，更大的命令队列，以及更有效的中断处理。

---------------------------

# SSD的种类
![不同协议不同规格](different_ssds.png)

## Breakfast

- Eat eggs
- Drink coffee

# In the evening

-----------------

## SATA


SATA (Serial Advanced Technology Attachment) refers to the technology standard for connecting hard drives, solid state drive, and optical drives to the computer’s motherboard. The SATA standard’s been in use for many years and is still the most prevalent interface for connecting internal storage drives.

The SATA standard has now undergone three major revisions, resulting in connectors that are identical in appearance (hurray for backwards compatibility), but with bandwidth doubling each time. This can cause some confusion in the event that you connect a hard drive that supports the SATA III standard into a SATA II connector, creating a bottleneck at the SATA II interface that will limit the potential bandwidth of the drive. But as it applies to SSDs, if you’re not using a SATA III connection, it’s safe to assume you’re limiting the potential of your drive. And even if you’re using a SATA III interface, you’re still probably limiting your SSD. In short, SATA just wasn’t made for solid state drives.

-------------------------
## NVME

NVM Express (NVMe) or Non-Volatile Memory Host Controller Interface Specification (NVMHCIS) is an open logical device interface specification for accessing non-volatile storage media attached via a PCI Express (PCIe) bus. The acronym NVM stands for non-volatile memory, which is often NAND flash memory that comes in several physical form factors, including solid-state drives (SSDs), PCI Express (PCIe) add in cards and other forms such as M.2 cards. NVM Express, as a logical device interface, has been designed from the ground up to capitalize on the low latency and internal parallelism of solid-state storage devices.

托于PCIe总线，NVMe设备可适用于各种支持PCIe总线的物理插槽上，包括标准尺寸的PCIe扩展卡（一般是4个PCIe通道）[2]、采用U.2物理连接界面（SFF-8639）的2.5英寸/3.5英寸标准尺寸固态硬盘驱动器、[3][4]SATA Express总线（兼容于PCIe）的设备、M.2规格扩展卡等

-------------------------


---------------

![SATA Speed](stat-speed.png)

--------------

## SLC vs MLC vs TLC vs QLC

In electronics, a multi-level cell (MLC) is a memory element capable of storing more than a single bit of information, compared to a single-level cell (SLC) which can store only one bit per memory element.

Triple-level cells (TLC) and quad-level cells (QLC) are versions of MLC memory, which can store 3 and 4 bits per cell, respectively. Note that due to the convention, the name "multi-level cell" is sometimes used specifically to refer to the "two-level cell", which is slightly confusing. Overall, the memories are named as follows:

    SLC (1 bit per cell) - fastest, highest cost
    MLC (2 bits per cell)
    TLC (3 bits per cell)
    QLC (4 bits per cell) - slowest, least cost

-------------


## 传输协议

- AHCI
- NVME（新）

## 传输物理接口

- SATA
- M.2（新）

## 传输总线

- PCIE（新）
- SATA
-------------

## SSD的结构

![蓝：7-pin SATA數據接口 绿：15-pin SATA電力接口 红：SandForce主控 黄：六片NAND Flash ](./Sf-ssd.png)

-------------

## Going to sleep
![不同m2 SSD大小](ssd size.jpg)

-------------

# 一些问题

-------------

## 我的苹果电脑是否可以换SSD
![2013年末的Macbook Pro with Retina display 型号：me293](mac.jpg)

-------------

## 机械硬盘 VS 固态硬盘（同容量）

- **重量** HDD > SSD
- **读写速度** SSD > HDD
- **噪音** HDD > SSD
- **价格** SSD > HDD


------------

# 推荐工具

## Linux

- lspci
- parted
- fdisk
- hdparm

## Windows

- HD Tune
- CrystalDiskInfo
- AS SSD Benchmark

------------

## 参考

- [Everything You Need to Know About SLC, MLC, & TLC NAND Flash](Everything You Need to Know About SLC, MLC, & TLC NAND Flash)
- [读pcie之一：从pcie速度说起](http://www.10tiao.com/html/609/201608/2652239634/1.html)
- [Testing SATA Express And Why We Need Faster SSDs](https://www.anandtech.com/show/7843/testing-sata-express-with-asus)
