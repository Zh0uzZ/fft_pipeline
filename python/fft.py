# fix2sfp
for i in range(1,19):
    print("5'd%d:begin\n  mantissa = fixin[%d] ? fixin[%d:%d]+1 : fixin[%d:%d];\n  exponent = %d;\nend" % (20-i,15-i,19-i,16-i,19-i,16-i,16-i))

for i in range(1,32):
    print("input_real[%d]," % (i-1) , end="")

print("\n\n{", end="") 
for i in range(1,33):
    print("input_imag[%d]," % (32-i) , end="")

print("}", end="")

print("\n\n{", end="") 
for i in range(1,33):
    print("twiddle_real[%d]," % (32-i) , end="")

print("}", end="")
print("\n\n{", end="") 
for i in range(1,33):
    print("twiddle_imag[%d]," % (32-i) , end="")

print("}", end="")
print("\n\n{", end="") 
for i in range(1,33):
    print("output_real[%d]," % (32-i) , end="")

print("}", end="")
print("\n\n{", end="") 
for i in range(1,33):
    print("output_imag[%d]," % (32-i) , end="")

print("}", end="")