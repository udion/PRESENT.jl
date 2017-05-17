using PyCall
@pyimport sys
@pyimport random

include("components.jl")

#function definitions to be used in the program
"""
a very subtle point is the bit positioning starts from 0 form RHS in
the paper but in implemetation in julia the positioning will be done
from 1 from LHS, so have to take care of conversion.
"""
################################################################################
#my definition of xor takes input of two binary string
#and returns a string which is xor of the two input string
function xor(binstr1::String,binstr2::String)
    l1 = length(binstr1)
    l2 = length(binstr2)
    if l1<l2
        bin(parse(Int128,binstr1,2)$parse(Int128,binstr2,2),l2) #avoid overlflow
    else
        bin(parse(Int128,binstr1,2)$parse(Int128,binstr2,2),l1)
    end
end

#definition of the sLayer(state)
#sLayer consists of 16 S-boxes in parallel (at the same level)
function sLayer(state)
    new_state = ""
    for i in 4:4:64
        new_nibble = S_box[state[i-3:i]]
        #join appends the strings inside array
        new_state = join([new_state,new_nibble])
    end
    state = new_state
end
#invsLayer consists of 16 S-boxes in parallel (at the same layer)
#and has the S-boxes in this layer has inverse mapping of the S-boxes in sLayer
function invsLayer(state)
  new_state = ""
  for i in 4:4:64
      new_nibble = invS_box[state[i-3:i]]
      #join appends the strings inside array
      new_state = join([new_state,new_nibble])
  end
  state = new_state
end

#definition of the pLayer(state)
function pLayer(state)
    l = length(state)
    newStateArray = fill('0',l)
    for i in 1:l
        newStateArray[P_box[l-i]+1] = state[l-i+1]
    end
    state = join(newStateArray)
end
#definition of the invpLayer, it maps the bits position in the manner
#which is inverse of what is present in the pLayer
function invpLayer(state)
  l = length(state)
  newStateArray = fill('0',l)
  for i in 1:l
      newStateArray[invP_box[l-i]+1] = state[l-i+1]
  end
  state = join(newStateArray)
end

#generic function to rotate the string by the given index
#in the right to left direction, needed to generate the round keys
function rotate_str(str,i)
    newstr = ""
    newstr = join([newstr,str[(i+1)%Int(length(str)):end]])
    newstr = join([newstr,str[1:(i%Int(length(str)))]])
end

#now the defintion of the genKeys(K_initial)
#function to generate the round keys using the master key, number of keys
#needed are 32, and the first key is master key itself
function genKeys(K_initial)
    k_array = fill("",32)
    k_array[1] = K_initial
    for i in 2:32
        k_array[i] = keyUpdate(k_array[i-1],i-1)
    end
    roundkeys = fill("",32)
    for i in 1:32
        roundkeys[i] = k_array[i][1:64]
    end
    roundkeys
end
# K is 80bits long
function keyUpdate(K,i)
    #first rortate by 61 bits to the left
    K_new = rotate_str(K, 61)
    #update the 4 left more bits as given
    K_l4 = S_box[K_new[1:4]]
    K_new = join([K_l4,K_new[5:end]])
    #do xor of K_new[20:16] from right hand side and round counter
    K_in = xor(K_new[61:65],bin(i,5))
    K_new = join([K_new[1:60],K_in,K_new[66:end]])
end

#some interconversion functions the input is a string and so is the output
function bin2hex(binstr::String, len::Int)
    hex(parse(Int128,binstr,2),len)
end

function hex2bin(hexstr::String, len::Int)
    bin(parse(Int128,hexstr,16),len)
end

#function to calculate HW of string
function HW(binstr::String)
    hw = 0
    for i in 1:length(binstr)
        if binstr[i] == '1'
            hw = hw+1
        end
    end
    hw
end

#function to genrate all permutaion of bit string of cetain length
list_perms = []
function bit_permutation(n)
    if n==1
        return ["0","1"]
    else
        perms1 = putcharinfront('1',bit_permutation(n-1))
        perms0 = putcharinfront('0',bit_permutation(n-1))
        res = append!(perms1,perms0)
    end
    res
end

function putcharinfront(a,listofstrings)
    for i in 1:length(listofstrings)
        listofstrings[i] = join([a,listofstrings[i]])
    end
    listofstrings
end

#definition for CSRNG, which takes input the upper and lower bound for integer
function csrngInt(low, high)
  r = random.SystemRandom()
  r[:randint](low,high)
end
################################################################################
