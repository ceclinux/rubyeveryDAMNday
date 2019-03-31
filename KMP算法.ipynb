{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "KMP算法的核心，是一个被称为部分匹配表(Partial Match Table)的数组。"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "```\n",
    "a b a b a b c a\n",
    "0 1 2 3 4 5 6 7\n",
    "0 0 1 2 3 4 0 1\n",
    "```"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "PMT中的值是字符串的前缀集合与后缀集合的交集中最长元素的长度"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "如何利用这个表来加速字符串的查找？"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "在i处失配，那么主字符串和模式字符串的前边6位就是相同的。又因为模式字符串的前6位，它的前4位和后4位后缀是相同的，所以我们推知主字符串i之前的4位和模式字符串开头的4位是相同的。就是图中的灰色部分。那这部分就不用再比较了"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "![](https://pic4.zhimg.com/v2-03a0d005badd0b8e7116d8d07947681c_r.jpg)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "为了编程的方便，我们不直接使用PMT数组，而是将PMT数组向后偏移一位。我们把新得到的这个数组称为`next`数组。其中需要注意的一个技巧是，在把PMT进行向右偏移时，第0位置的值，我们将其设置成了-1，这只是为了编程的方便，并没有其他的意义。"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "```\n",
    "a  b a b a b c a\n",
    "0  0 1 2 3 4 0 1\n",
    "-1 0 0 1 2 3 4 0\n",
    "```"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "现在，我们再看一下如何编程快速求得`next`数组。其实，求`next`数组的过程完全可以看成字符串匹配的过程，即以模式字符串为主字符串，以模式字符串的前缀位目标字符串，一旦字符串匹配成功，那么当前的`next`值就是匹配成功的字符串长度"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "![](https://pic1.zhimg.com/80/v2-645f3ec49836d3c680869403e74f7934_hd.jpg)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "![](https://pic3.zhimg.com/80/v2-06477b79eadce2d7d22b4410b0d49aba_hd.jpg)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "![](https://pic1.zhimg.com/80/v2-8a1a205df5cad7ab2f07498484a54a89_hd.jpg)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "![](https://pic2.zhimg.com/80/v2-f2b50c15e7744a7b358154610204cc62_hd.jpg)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "![](https://pic2.zhimg.com/80/v2-bd42e34a9266717b63706087a81092ac_hd.jpg)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 4,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       ":KMP"
      ]
     },
     "execution_count": 4,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "\n",
    "# @param {String} haystack\n",
    "# @param {String} needle\n",
    "# @return {Integer}\n",
    "def str_str(haystack, needle)\n",
    "    return 0 if needle == \"\"\n",
    "    KMP(needle, haystack)\n",
    "end\n",
    "def get_next(str)\n",
    "  next_arr = [-1]\n",
    "  i = 0\n",
    "  j = -1\n",
    "  while i < str.size\n",
    "    if j == -1 || str[i] == str[j]\n",
    "      i += 1\n",
    "      j += 1\n",
    "      next_arr << j\n",
    "    else\n",
    "      j = next_arr[j]\n",
    "    end\n",
    "  end\n",
    "  next_arr\n",
    "end\n",
    "def KMP(needle, haystack)\n",
    "  i = 0\n",
    "  j = 0\n",
    "  next_arr = get_next(needle)\n",
    "  while j < needle.size && i < haystack.size\n",
    "    if j == -1 || haystack[i] == needle[j]\n",
    "      return i - j if j == (needle.size - 1)\n",
    "      i += 1\n",
    "      j += 1\n",
    "    else\n",
    "      j = next_arr[j]\n",
    "    end\n",
    "  end\n",
    "  -1\n",
    "end\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 6,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "2"
      ]
     },
     "execution_count": 6,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "str_str(\"ababababca\", \"abababca\")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "`get_next`的`while`循环中， 可以得出\n",
    "\n",
    "1. `j`一开始就比`i`要小\n",
    "2. `j`在加的时候`i`也在加\n",
    "3. `j = next_arr[j]`使得`j`在减少\n",
    "\n",
    "而`i`最多加`str.size - 1`次，故`j`也只能减`str.size - 1`次"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Ruby 2.5.1",
   "language": "ruby",
   "name": "ruby"
  },
  "language_info": {
   "file_extension": ".rb",
   "mimetype": "application/x-ruby",
   "name": "ruby",
   "version": "2.5.1"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 2
}
