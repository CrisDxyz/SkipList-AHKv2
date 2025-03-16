#Requires Autohotkey v2.0+
#Include Dim_Echo_Box.ahk

/*
===============================================================
Skip List - Data Structure Implementation in AHK v2
===============================================================
Version: 0.9
Created by: CrisDxyz
Date: Today
License: MIT License
Github: https://github.com/CrisDxyz/SkipList-AHKv2/

===============================================================
Description & Usage:

Just "#Include" this script into yours, 
and save SkipList() into a variable to use it;

Example script to test it:

#Requires Autohotkey v2.0+
#Include "SkipList_AHKv2.ahk"

RandomWord(length := 5) {
    chars := "abcdefghijklmnopqrstuvwxyz"
    word := ""
    loop length
        word .= SubStr(chars, Random(1, 26), 1)
    return word
}

StressTestList := SkipList()

StressTestList.Echo_Display()

i := 1

AppendToEcho("`t`n >> Inserting Numbers: `n")

; Increase loops if you want

loop 1 {
	while i<50 {
		StressTestList.Insert(Random(0, 9999))
        StressTestList.Insert(RandomWord())
		i:=i+1
	}
	StressTestList.Echo_Display()
	StressTestList.Echo_Display_Level(1)
	StressTestList.Echo_Display_Level(2)
	StressTestList.Echo_Display_Level(3)
	i:=0
	AppendToEcho("`t`n >> Total number of elements: `n" . StressTestList.Count())
}

AppendToEcho("`t`n >> Removing Numbers: `n")

loop 1 {
	while i<500 {
		StressTestList.Remove(Random(0, 9999))
                StressTestList.Remove(RandomWord())
		i:=i+1
	}
	StressTestList.Echo_Display()
	StressTestList.Echo_Display_Level(1)
	StressTestList.Echo_Display_Level(2)
	StressTestList.Echo_Display_Level(3)
	i:=0
	AppendToEcho("`t`n >> Total number of elements: `n" . StressTestList.Count() "`n")
}

StressArray := StressTestList.ToArray()
Echo(StressArray)

Check https://www.autohotkey.com/docs/v2/lib/_Include.htm#ExFile 

===============================================================
Credits and Acknowledgments:
- Development: CrisDxyz (Me)

===============================================================
To do/future plans:
mix echo & non-echo funcs, i can be lazy sometimes y'know
get arrays working, maybe

===============================================================
Disclaimer:
This thing is provided "as is," without warranty of any kind. 

===============================================================
*/


class SkipListNode {
    __New(value, level) {
        this.value := value
        this.next := []
        Loop level{
            this.next.Push(0) ; Initialize next pointers to null
        }
    }
}

class SkipList {
    __New(maxLevel := 4, p := 0.25) { ; <<< Coin toss %%s & towers height <<< 
        this.maxLevel := maxLevel
        this.p := p ; Probability factor for level generation
        this.head := SkipListNode(0, maxLevel) ; Head node (dummy node)
        
        ; Initialize head's next pointers
        Loop maxLevel{
            this.head.next.Push(0)
        }
    }

    RandomLevel() {
        level := 1
        While (level < this.maxLevel && (Random(0, 100) / 100.0) < this.p) {
            level++
        }
        return level
    }
	
    CompareValues(a, b) { ; still thinking about this one and arrays
		if IsObject(a) && IsObject(b) {
			return (a.Length < b.Length) ? -1 : (a.Length > b.Length) ? 1 : 0
		}
		if IsObject(a) || IsObject(b) { ; Prevent comparing object with non-object
			return 0
		}
		if (IsNumber(a) && IsNumber(b)) {
			return (a < b) ? -1 : (a > b) ? 1 : 0
		}
		if (a Is String && b Is String) {
			return (StrCompare(a, b) < 0) ? -1 : (StrCompare(a, b) > 0) ? 1 : 0
		}
		return 0 ; Default case if types mismatch
	}

    Insert(value) {
        update := [] ; Track path for inserting node
        current := this.head
		
		; Normalize data int -> strings
		if !(value Is String){
			value := value ""  ; Ensure everything is a string
		}

        ; Ensure update array is properly initialized
        Loop this.maxLevel{
            update.Push(this.head)
        }

        ; Traverse the list from highest level down
        Loop this.maxLevel {
            i := this.maxLevel - A_Index + 1 ; Reverse loop
            While (IsObject(current.next[i]) && this.CompareValues(current.next[i].value, value) < 0) {
                current := current.next[i]
            }
            update[i] := current ; Store update path
        }

        level := this.RandomLevel()
        newNode := SkipListNode(value, level)

        ; Ensure newNode.next has the correct size
        Loop level {
            newNode.next.Push("")
        }

        ; Insert the new node and update pointers
        Loop level {
            index := A_Index
            if (IsObject(update[index])) {
                newNode.next[index] := update[index].next[index]
                update[index].next[index] := newNode
            }
        }
    }
	
    Remove(value) {
        update := [] ; Track path for removal
        current := this.head

        ; Initialize update array
        Loop this.maxLevel {
            update.Push(this.head)
	}

        ; Traverse the list and store update path
        Loop this.maxLevel {
            i := this.maxLevel - A_Index + 1 ; Reverse loop
            While (IsObject(current.next[i]) && this.CompareValues(current.next[i].value, value) < 0) {
                current := current.next[i]
            }
            update[i] := current ; Store the last node before target
        }

        ; Target node found?
        target := current.next[1]
        if (!IsObject(target) || target.value != value){
            return False ; Value not found
        }

        ; Remove references to the target node
        Loop this.maxLevel {
            if (update[A_Index].next[A_Index] != target){
                Break
            }
            update[A_Index].next[A_Index] := target.next[A_Index]
        }
    
        return True
    }

    Search(value) {
        current := this.head
        Loop this.maxLevel {
            i := this.maxLevel - A_Index + 1 ; Reverse loop
            While (IsObject(current.next[i]) && this.CompareValues(current.next[i].value, value) < 0){
                current := current.next[i]
            }
        }
        return (IsObject(current.next[1]) && this.CompareValues(current.next[i].value, value) = 0) ? True : False
    }

    Contains(value) {
        return this.Search(value) ? true : false
    }

    Count() {
        count := 0
        current := this.head.next[1]
        while (IsObject(current)) {
            count++
            current := current.next[1]
        }
        return count
    }

    Display() {
        current := this.head.next[1]
        output := "Skip List Elements: `n`t"
        While (IsObject(current)) {
            output .= (IsObject(current.value) ? "[" current.value.Length " items]" : current.value) . " -> "
            current := current.next[1]
        }
        MsgBox output . "NULL"
    }

    Echo_Display() {
        current := this.head.next[1]
        output := "`n Skip List Elements: `n`t"
        While (IsObject(current)) {
            output .= (IsObject(current.value) ? "[" current.value.Length " items]" : current.value) . " -> "
            current := current.next[1]
        }
        AppendToEcho("`n" . output . "NULL" . "`n")
		
    }
    
    Display_Level(level_number) {
        ; Validate the level number
        if (level_number < 0 || level_number >= this.maxLevel) {
            MsgBox "Error: Level number " level_number " is out of bounds."
            return
        }

        ; Start at the head's pointer for the specified level
        current := this.head.next[level_number]
        output := "Skip List Level " level_number " Elements:`n`t"
    
        ; Traverse nodes on this level and build the display string
        while (IsObject(current)) {
            output .= (IsObject(current.value) ? "[" current.value.Length " items]" : current.value) . " -> "
            current := current.next[level_number]
        }
    
        MsgBox output . "NULL"
    }

    Echo_Display_Level(level_number) {
        ; Validate the level number
        if (level_number < 0 || level_number >= this.maxLevel) {
            MsgBox "Error: Level number " level_number " is out of bounds."
            return
        }

        ; Start at the head's pointer for the specified level
        current := this.head.next[level_number]
        output := "`n  Skip List Level " level_number " Elements:`n`t"
    
        ; Traverse nodes on this level and build the display string
        while (IsObject(current)) {
            output .= (IsObject(current.value) ? "[" current.value.Length " items]" : current.value) . " -> "
            current := current.next[level_number]
        }
    
        AppendToEcho("`n" . output . "NULL" . "`n")
		
    }

    Display_Duplicates() {
		; Create a map to store counts for each value.
		counts := Map()
		
		; Traverse the bottom level (level 0) of the skip list.
		current := this.head.next[1]
		
		while (IsObject(current)) {
			
			val := current.value
			
			; Check if the key already exists; if yes, increment, if not, initialize to 1.
			if (counts.Has(val)){
				counts[val]++
			}
			
			else{
				counts.Set(val, 1)
			}
			
			current := current.next[1]
		}
		
		; Build an output string for duplicate values.
		output := "Duplicate Counts:`n"
		duplicatesFound := false
		for key, count in counts {
			if (count > 1) {
				output .= "`"" key "`" is contained " count " times `t`n"
				duplicatesFound := true
			}
		}
		
		if (!duplicatesFound){
			output .= "No duplicates found."
		}
		
		MsgBox output
	}

    Echo_Display_Duplicates() {
		; Create a map to store counts for each value.
		counts := Map()
		
		; Traverse the bottom level (level 0) of the skip list.
		current := this.head.next[1]
		
		while (IsObject(current)) {
			val := current.value
			; Check if the key already exists; if yes, increment, if not, initialize to 1.
			if (counts.Has(val))
				counts[val]++
			else
				counts.Set(val, 1)
			current := current.next[1]
		}
		
		; Build an output string for duplicate values.
		output := "Duplicate Counts:`n"
		duplicatesFound := false
		
		for key, count in counts {
			if (count > 1) {
				output .= "`"" key "`" is contained " count " times`n"
				duplicatesFound := true
			}
		}
		
		if (!duplicatesFound){
			output .= "`nNo duplicates found.`n"
		}
		
		AppendToEcho("`n" . output . "`n")
		
	}

    ToArray() {
        arr := []
        current := this.head.next[1]
        while (IsObject(current)) {
            arr.Push(current.value)
            current := current.next[1]
        }
        return arr
    }

}
