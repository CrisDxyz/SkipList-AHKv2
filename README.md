# SkipList-AHKv2
Skip list data structure implemented in AutoHotkey v2. Includes funcs to use Dim Echo Box (https://github.com/CrisDxyz/Dim_Echo_Box) instead of MsgBox for data display.

# What is a [Skip list](https://en.wikipedia.org/wiki/Skip_list)?
It's a probabilistic data structure with Θ(log(n)) time complexity on best case, O(n) on worst. Space complexity of O(n log(n)). Check [Big-O Cheat sheet](https://www.bigocheatsheet.com/) for more info.

# Wikipedia Visual Example

![](https://upload.wikimedia.org/wikipedia/commons/2/2c/Skip_list_add_element-en.gif)

## Features

- **Insertion:** Add elements with automatic level determination.
- **Search:** Fast lookups in O(log n) time on average.
- **Removal:** Delete elements while maintaining skip list integrity.
- **Display Functions:** Show entire list or specific levels.
- **Duplicate Detection:** Identify and count duplicate elements.

# Stress test using numbers
Also, use [Dim Echo Box](https://github.com/CrisDxyz/Dim_Echo_Box) to display data instead of MsgBox, since you will reach the character limit quite fast.

![](https://github.com/CrisDxyz/SkipList-AHKv2/blob/main/img/AHKv2%20MsgBox%20Character%20limit%20vs%20DEB.png)

