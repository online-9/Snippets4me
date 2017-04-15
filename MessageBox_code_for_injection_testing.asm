xor ecx, ecx;
mov eax, fs:[ecx + 0x30]; // eax = PEB ; xor ecx, ecx; and don't use null bytes: mov eax, fs:[0x30]
mov eax, [eax + 0xc]; // eax = PEB->Ldr;
mov esi, [eax + 0x14]; // esi = PEB->Ldr.InMemOrder
lodsd; // EAX = Second Module; The “lodsd” instruction will follow the pointer specified by the esi register and we will have the result in the eax register ...
xchg eax, esi; // lodsd is like: eax = *esi and esi+=4
lodsd; // Since the order of the loaded modules can change, we should check the full name in order to choose the right DLL that is containing the function we are looking for, but for testing purposes it's okay :)
mov ebx, [eax + 0x10]; // ebx = Base address of kernel32.dll
// now we have kernel32.dll in memory in EBX

mov edx, [ebx + 0x3c]; // edx = e_lfanew;
add edx, ebx;          // edx = PE + e_lfanew: PE Header
mov edx, [edx + 0x78]; // PE header address + 120 byte
add edx, ebx;          // data dir[0] + Base address = data dir; data dir[0] = export table; edx = offset export table
mov esi, [edx + 0x20]; 
add esi, ebx;   // export table + 0x20 = AddressOfNames
xor ecx, ecx;
// esi = AddressOfNames, an array of pointers.
// each points to function name
Get_ptr: // find function name and ordinal of function
inc ecx; // ordinal
lodsd; // eax = *esi; esi+=4; name offset; esi:AddressOfNames
add eax, ebx; // + BaseAddress = function name;
cmp dword ptr[eax], 0x50746547;  // ...first part
jnz Get_ptr;
cmp dword ptr[eax + 4], 0x41636f72;  // ...in hex
jnz Get_ptr;
cmp dword ptr[eax + 8], 0x65726464;  // kernel32.dll
jnz Get_ptr;
// eax = GetProccessAddress
// we have ordinal of GetProcessAddress
// find address of GetProcessAddress

mov esi, [edx + 0x24]; // esi = IMAGE_EXPORT_DIR + 0x42 == AddressOfNameOrdinals
add esi, ebx; // ebx = image base
mov cx, [esi + ecx * 2]; // array of two byte numbers
dec ecx; // starts from 0
mov esi, [edx + 0x1c]; // 0x1c AddressOfFunctions
add esi, ebx;
mov edx, [esi + ecx * 4]; // AddressOfFunctions[ecx] == GetProcessAddress
add edx, ebx;
// edx == address of GetProcessAddress

xor ecx, ecx; // for string end. ECX = 0
push ebx; // Kernel32 base address
push edx; // GetProcAddress
push ecx; // \0
push 0x41797261; // aryA
push 0x7262694c; // Libr
push 0x64616f4c; // Load
push esp; // "LoadLibrary"
push ebx; // Kernel32 base address
call edx; // GetProcAddress(LL)
// eax = LoadLibraryA


add esp, 0xC; // get rid of "LoadLibraryA" string
pop ecx;
push eax; // save address of LoadLibraryA
// call LoadLibrary("user32.dll")
push ecx;
mov cx, 0x6c6c; // 'll' part of user32.dll
push ecx;
push 0x642e3233; // 32.d
push 0x72657375; // user
push esp; // "user32.dll"
call eax; // LoadLibrary("user32.dll")

// GetProcessAddress(LoadLibrary("user32.dll"), "MessageBoxA")
add esp, 0x10; // clean stack
mov edx, [esp + 0x4];  // saved GetProcessAddress in edx;
mov ecx, 0x41786f; // push "oxA";
push ecx;
push 0x42656761; // ageB
push 0x7373654d; // Mess
push esp; // "MessageBoxA"			
push eax; // user32.dll address
call edx; // GetProc(MessageBoxA)

// MessageBoxA(0, L"abcd", L"abcd", 0);
add esp, 0x10;
push 0x64636261; // Caption
sub dword ptr[esp + 0x3], 0x64; // 'd' - 'd' = 0
mov esi, esp; // save Caption/text
xor ecx, ecx;
push ecx; // 0
push esi; // abc
push esi; // abc
push ecx; // 0
call eax; // MessageBoxA(0, "abc", "abc", 0);
