# PRESENT.jl
This package implements the PRESENT encryption algorithm as proposed in the paper<br>
[PRESENT: An Ultra-Lightweight Block Cipher](http://lightweightcrypto.org/present/present_ches2007.pdf)

The package implements the 80-bit key version which is quite popular and conceptually same as 128-bit key version.

# Installation
In julia prompt do Pkg.clone("https://github.com/udion/PRESENT.jl")

# Usages
The module provides two functions : <br>
* PRESENTenc(::String, ::String)
* PRESENTdec(::String, ::String)
<br> both functions take 2 input paprameters the first one being the **key** and second one as **inputState**.<br>
Both the input are expected to be in hexadecimal format (**without 0x**), also since PRESENT is designed to be used on
64-bits state, in the hexadecimal format the string length of 16 well acommodates the possible domains for input.

```
k_master = "ff1234abc"
input = "6789ffaed"
encrypted = PRESENTenc(k_master,input)
decrypted = PRESENTdec(k_master,encrypted)
```

```
julia>encrypted
"b376caacdcb790e7"

julia>decrypted
"00000006789ffaed"
```
