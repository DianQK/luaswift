local sum = 1.2
for i = 1, 8 do
  if i % 2 == 0 then
    sum = sum + sum + i
  end
end
-- print(sum) 71.2
