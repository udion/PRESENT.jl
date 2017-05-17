#S-box, P-box implemented as given in the research paper
#########################################################################
S_val = [bin(0xc,4), bin(0x5,4), bin(0x6,4), bin(0xb,4),
bin(0x9,4), bin(0x0,4), bin(0xa,4), bin(0xd,4), bin(0x3,4),
bin(0xe,4), bin(0xf,4), bin(0x8,4), bin(0x4,4), bin(0x7,4),
bin(0x1,4), bin(0x2,4)]
S_box = Dict()
for i in range(0,16)
    S_box[bin(i,4)] = S_val[i+1]
end
#now I'll create the Permutation to represent P_box (src: research ppr)
P_val = [0,16,32,48,1,17,33,49,2,18,34,50,3,19,35,51,4,20,36,
52,5,21,37,53,6,22,38,54,7,23,39,55,8,24,40,56,9,25,41,57,
10,26,42,58,11,27,43,59,12,28,44,60,13,29,45,61,14,30,46,62,15,31,47,63]
P_box = Dict()
for i in range(0,64)
    P_box[i] = P_val[i+1]
end

########### needed for decryption ######################
#i need the inverse of the S_box as invS_box
invS_box = Dict()
for i in 0:15
    t = bin(i,4)
    invS_box[S_box[t]] = t
end
#also need an inverse P-box invP_box
invP_box = Dict()
for i in range(0,64)
    invP_box[P_box[i]] = i
end
#########################################################################

#this type will  collect the data from a particular round of encrypter
type roundData
    inp::String
    key::String
    outp::String
end
undef_round = roundData("undef","undef","undef")
