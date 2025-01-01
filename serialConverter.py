# NOTE: Pilfered from https://github.com/NiLuJe/KindleTool/blob/master/tools/kindle_model_sort.py#L26
# NOTE: Pilfered from https://stackoverflow.com/questions/1119722/
BASE_LIST = tuple("0123456789ABCDEFGHJKLMNPQRSTUVWX")
BASE_DICT = dict((c, v) for v, c in enumerate(BASE_LIST))
BASE_LEN = len(BASE_LIST)

def devCode(string):
	num = 0
	for char in string:
		num = num * BASE_LEN + BASE_DICT[char]
	return num

# BionicGecko's ColorSoft
print(hex(devCode("3H7")))