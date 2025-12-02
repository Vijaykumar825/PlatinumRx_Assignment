def convert_minutes(m):
    hrs = m // 60
    mins = m % 60
    
    if hrs == 0:
        return f"{mins} minutes"
    if mins == 0:
        return f"{hrs} hrs"
    return f"{hrs} hrs {mins} minutes"

print(convert_minutes(130))
print(convert_minutes(110))
#To take user input, uncomment the line below
# print(convert_minutes(int(input("Enter minutes: "))))