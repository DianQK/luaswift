echo "$1" > "$1.csv"

max=1000
for i in `seq 1 $max`
do
    ./DerivedData/Lua/Build/Products/Release/Lua luacode/ch10/fibonacci.luac >> "$1.csv"
done
