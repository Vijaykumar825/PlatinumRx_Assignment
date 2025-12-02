def unique_string(s):
    seen = set()
    out = ""
    for ch in s:
        if ch not in seen:
            seen.add(ch)
            out += ch
    return out

print(f"the unique elements in string is -> {unique_string("banana")}")
#for user input, uncomment the line below
# print(unique_string(input("Enter a string: ")))