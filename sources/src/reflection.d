// reflection 
	
private	import std.stdio;
private import std.stream; 
private import std.conv;
private import std.ctype;
private import std.regexp;
private import std.stdio;
private import std.string;
private import std.c.stdlib;
private import std.thread;

version (Windows) {
	version = classDoubleUnderbar;
}
version (darwin) {
	version = classDoubleUnderbar;
	version = methodDoubleUnderbar;
}

private {
	version (classDoubleUnderbar) {
		char[] classStr = `__Class_`;
		char[] classDStr = `__Class__D`;
	}
	else {
		char[] classStr = `_Class_`;
		char[] classDStr = `_Class__D`;
	}
	version (methodDoubleUnderbar) {
		char[] methodStr = `__D`;
	}
	else {
		char[] methodStr = `_D`;
	}
}

/// utility function
private bool startWith(char[] s1, char[] s2) {
	return cast(bool)(s1.length >= s2.length && s1[0..s2.length] == s2);
}

extern (C) void* _d_newclass(void*);
extern (C) void _d_delclass(void**);
 
private class Demangle { 
	this() {
	}

	char[][] demangleName(char[] sym) {
		int i = 0;
		return demangleName(sym, i);
	}

	char[][] demangleName(char[] sym, inout int i) {
		if (sym[i..sym.length].startWith(methodStr)) i += methodStr.length;

		char[][] names;
		while (i < sym.length && std.ctype.isdigit(sym[i])) {
			int num = getNum(sym, i);

			char[] now = sym[i..i+num];

			if (now == "__anonymous") {
			}
			else {
				// we cannot demangle template correctly!
/*
				int sep = rfind(now, "_");
				if (sep > 0) {
					try {
						int dummy = sep+1;
						int prev = dummy;
						char[][] types;
						while (dummy != now.length) {
							Type t = demangleType(now, dummy);
							if (prev == dummy || t is null) goto TEMPLATE_END;
							prev = dummy;
							types ~= t.toString;
						}
						now = now[0..sep] ~ "!(" ~ join(types,`,`) ~ ")";
					}
					catch (Object o) {}
				}
			TEMPLATE_END:
*/
				names ~= now;
			}

			i += num;
		}

		return names;
	}

	Type demangleType(char[] sym, inout int i) {
		Type type = new Type();

		switch (sym[i]) {
		case 'A': { // array
			i++;
			type = demangleType(sym, i);
			type.qual |= Type.Qual.ARRAY;
			return type;
		}
		case 'G': { // static array
			i++;
			char[] num = getNumStr(sym, i);
			type = demangleType(sym, i);
			type.qual |= Type.Qual.SARRAY;
			return type;
		}
		case 'H': { // assoc array
			i++;
			type.assoc = demangleType(sym, i);
			type = demangleType(sym, i);
			type.qual |= Type.Qual.ASSOC;
			return type;
		}
		case 'P': { // pointer
			i++;
			type = demangleType(sym, i);
			type.qual |= Type.Qual.POINTER;
			return type;
		}
		case 'K': { // inout
			i++;
			type = demangleType(sym, i);
			type.qual |= Type.Qual.INOUT;
			return type;
		}
		case 'J': { // out
			i++;
			type = demangleType(sym, i);
			type.qual |= Type.Qual.OUT;
			return type;
		}
		case 'R': { // reference
			assert(false);
//			i++;
//			type = demangleType(sym, i);
//			type.qual = Type.Qual.REFERENCE;
//			return type;
		}
		case 'I': { // @@@ident?
			assert(false);
		}
		case 'C': { // class
			type.kind = Type.Kind.KLASS;
			i++;
			char[][] t = demangleName(sym, i);
			// @@@
			type.klass = Class.forName(join(t, `.`));
			return type;
		}
		case 'S': { // struct
			type.kind = Type.Kind.UNKNOWN;
			i++;
			char[][] t = demangleName(sym, i);
			// @@@
			type.unknown = join(t, `.`);
			return type;
		}
		case 'E': { // enum
			type.kind = Type.Kind.UNKNOWN;
			i++;
			char[][] t = demangleName(sym, i);
			// @@@
			type.unknown = join(t, `.`);
			return type;
		}
		case 'T': { // typedef
			type.kind = Type.Kind.UNKNOWN;
			i++;
			char[][] t = demangleName(sym, i);
			// @@@
			type.unknown = join(t, `.`);
			return type;
		}
		case 'Y':
		case 'Z': { // separater
			return null;
		}
		case 'D': { // delegate
			i++;
			type = demangleType(sym, i);
			assert(type.kind == Type.Kind.FUNC);
			type.func.qual = Function.FQual.DELEGATE;
			return type;
		}
		case 'F':
		case 'U': { // (static) function
			type.kind = Type.Kind.FUNC;
			type.func = new Function();
			if (sym[i] == 'U') type.func.qual |= Function.FQual.STATIC;

			i++;
			Type[] args;
			bool nowRet = false;
			while (1) {
				Type t = demangleType(sym, i);

				if (nowRet) {
					type.func.ret = t;
					type.func.args = args;
					return type;
				}
				if (i == sym.length) {
					type.func.ret = t;
					Type n = new Type;
					n.kind = Type.Kind.BUILTIN;
					n.builtin = new Builtin(Builtin.Type.ARGS);
					args ~= n;
					type.func.args = args;
					return type;
				}

				if (t) args ~= t;

				if (sym[i] == 'Z') {
					nowRet = true;
					i++;
				}
				if (sym[i] == 'Y') {
					i++;
				}
			}
			assert(false);
		}
		default:
			type.kind = Type.Kind.BUILTIN;
			try {
				type.builtin = new Builtin(sym[i]);
			}
			catch (Error e) {
				throw new Error(sym ~ ": cannot demnagle");
			}
			i++;
			return type;
		}
		return null;
	}

	Method demangleMethod(char[] sym) {
		int i = 0;
		return demangleMethod(sym, i);
	}

	Method demangleMethod(char[] sym, inout int i) {
		if (sym[i..sym.length].startWith(methodStr)) i += methodStr.length;

		char[][] names = demangleName(sym, i);

		char[] name = join(names, `.`);

		if (name == "") return null;

		assert(sym.length != i);

		Type type = demangleType(sym, i);

		Method ret = new Method();

		ret.fullname = name;
		ret.name = name;
		ret.type = type;

		int seps = names.length - 1;
		Class c = Class.forName(join(names[0..seps], `.`));
		if (c) {
			ret.klass = c;
			ret.name = names[seps];
			c.methods ~= ret;
		}

		return ret;
	}

private:
	bool issym(char c) {
		return cast(bool)(isalnum(c) || c == '_');
	}

	int getNum(char[] str, inout int i) {
		return toInt(getNumStr(str, i));
	}
	char[] getNumStr(char[] str, inout int i) {
		char[] numStr = "";
		while (std.ctype.isdigit(str[i])) {
			numStr ~= str[i];
			i++;
		}
		return numStr;
	}

private:

}
 
extern (C) { 
	typedef int (*CompareFunction)(void*,void*);

	void *bsearch(void* key, void* base, uint nmemb, uint size,
				  int (*compar)(char[], char[]));

	int dstrcmp_(char[]* sp1, char[]* sp2) {
		char[] s1 = *sp1;
		char[] s2 = *sp2;
		if (s1.length < s2.length) return -1;
		else if (s1.length > s2.length) return 1;
		for (int i = 0; i < s1.length; i++) {
			if (s1[i] < s2[i]) return -1;
			else if (s1[i] > s2[i]) return 1;
		}
		return 0;
	}
}
 
// all members are static
class Reflection { 
	
public:
	static void init(char[] nmfile) { 
		auto Demangle demangler = new Demangle();

		version (Windows) {
			if(nmfile[nmfile.length-3..nmfile.length]=="exe"){
				loadDebug(nmfile);
			}else{
				loadMapFile(nmfile);
			}
		}
		else {
			loadNmFile(nmfile);
		}
		syms = sym2addr.keys;
		try{
			qsort(&syms[0], syms.length, syms[0].sizeof,
				  cast(CompareFunction)&dstrcmp_);
		}catch(Exception e){
			return;
		}
		initClass(demangler);
		initMethod(demangler);
	    initStackTrace();
	}
 
public:
	static void* getAddr(char[] sym) { return sym2addr[sym]; } 
 
	static ushort getLine(void* addr) { return addr2line[cast(uint)addr]; } 
 
private:
	static void initClass(Demangle d) { 
		foreach (char[] sym; syms) {
			if (sym.startWith(classStr)) {
				if (sym.startWith(classDStr)) {
					// class in function.
					continue;
				}
				char[][] seps =
					d.demangleName(sym[classStr.length..sym.length]);
				Class c = new Class();
				c.name = join(seps, `.`);
				c.sym = sym;
				c.address = getAddr(sym);
				Class.classes[c.name] = c;
			}
		}
	}
 
	static void initMethod(Demangle d) { 
		foreach (char[] sym; syms) {
			if (sym.startWith(methodStr)) {
				Method m = d.demangleMethod(sym);
				if (m is null) continue;
				m.sym = sym;
				m.address = getAddr(sym);
			}
		}
	}
 
	static void loadNmFile(char[] nmfile) { 
		File f = new File(nmfile);
		char[] line;
		while ((line = f.readLine()) != null) {
			if (line[0] == ' ') continue;

			void* addr;
			sscanf(toStringz(line[0..8]), "%x", &addr);
			sym2addr[line[11..line.length]] = addr;
		}
	}
 
	static void loadMapFile(char[] nmfile) { 
		File f = new File(nmfile);
		char[] line;
		RegExp reg = new RegExp(` [\dABCDEF]{4}:[\dABCDEF]{8}\s{7}(.*)`, ``);

		while (!f.eof()) {
			line = f.readLine();
			if (reg.test(line) == 0) continue;
			line = reg.replace(`$1`);
//			char[][] seps = line.split();				// <- under ver 0.113
			char[][] seps = std.string.split(line);		// <-  over ver 0.114
			if (seps.length != 2) continue;
			void* addr;
			sscanf(toStringz(seps[1]), "%x", &addr);
//			writefln("0x%p:%.*s",addr,seps[0]);
			sym2addr[seps[0]] = addr;
		}
	}
 
	static void loadDebug(char[] nmfile) { 
//		writefln("loaddebug");
		auto DebugInfo di = new DebugInfo(nmfile);
		sym2addr = di.getSymToAddr();
//		foreach(char[] sym,void* addr;sym2addr){
//			writefln("%d:%.*s",addr,sym);
//		}
		addr2line = di.getAddrToLine();
//		foreach(uint addr,ushort line;addr2line){
//			writefln("%08x:(%d)",addr,line);
//		}
	}
 
private: 
	static void*[char[]] sym2addr;
	static char[][] syms;
	static ushort[uint] addr2line;
 
// stackTrace 
private:
	static uint[][uint] addrStack;
	static uint[][uint] returnAddrStack;
	static uint[][uint] stackAddrStack;
	static char[][uint] addr2sym;
 
	static void initStackTrace(){ 
	    foreach (char[] kc, Class c; Class.classes) {
	        foreach (Method m; c.methods) {
	        	uint address;
	        	if(m.name=="_ctor"){
		            address = cast(uint)m.address+0x14;
		        }else{
		            address = cast(uint)m.address;
		        }
	            addr2sym[address] = m.fullname;
	//            writefln("%.*s:%.*s",address,m.fullname);
	        }
	    }
	    ClassInfo ci = Object.classinfo;
	    ci.classInvariant = &invariantMethod;
	}
 
	static void invariantMethod(Object o){ 
		uint *dummy;
		dummy=cast(uint*)&dummy;
		saveStack(dummy);
	}
	
	static void saveStack(uint* dummy){ 
		uint address = dummy[6]-5;
		uint stackAddr=cast(uint)dummy;
		//writefln("%08x (%d)",dummy[9],Reflection.getLine(cast(void*)dummy[9]));
		for(int i=0;i<20;i++){
			if(!(address in addr2sym)){
				address=address-1;
			}else{
				break;
			}
		}
		uint threadid=cast(uint)(Thread.getThis().hdl);
		uint[] returnStackData=returnAddrStack[threadid];
		uint[] stackData=addrStack[threadid];
		uint[] stackDataStack=stackAddrStack[threadid];
		for(int i=0;i<stackData.length;i++){
			if(stackDataStack[i] <= stackAddr){
				stackDataStack.length = i;
				stackData.length = i;
				returnStackData.length = i;
				break;
			}
		}
		stackDataStack ~= stackAddr;
		stackData ~= address;
		returnStackData ~= dummy[9];
		stackAddrStack[threadid]=stackDataStack;
		addrStack[threadid]=stackData;
		returnAddrStack[threadid]=returnStackData;
//		writefln("call function %.*s address(%d)",addr2sym[address],address);
	}
  
public:
	static char[] stackTrace(){ 
		char[] str;
		uint threadid=cast(uint)(Thread.getThis().hdl);
		uint[] stackData=addrStack[threadid].dup.reverse;
		uint[] returnStackData=returnAddrStack[threadid].dup.reverse;
		for(int i=0;i<stackData.length;i++){
			uint address = stackData[i];
			uint returnAddress = returnStackData[i];
			ushort line = Reflection.getLine(cast(void*)address);
			char[] linestr="";
			if(line!=0)linestr = "("~std.string.toString(line)~")";

			ushort returnLine = Reflection.getLine(cast(void*)returnAddress);
			char[] returnLinestr="";
			if(returnLine!=0)returnLinestr = " return("~std.string.toString(returnLine)~")";

			if(address in addr2sym){
				str = str ~ "  at "~addr2sym[address] ~linestr~returnLinestr~"";
			}else{
				str = str ~ "  at ? "~linestr~returnLinestr~"";
			}
		}
		return str;
	}
 
} 
  
class Class { 
public:
	char[] sym;
	char[] name;
	void* address;
	Method[] methods;

	static Class forName(char[] name) {
		if (!(name in classes)) return null;
		return classes[name];
	}

	static Class[char[]] classes;
}
 
class Method { 
	char[] sym;
	char[] fullname;
	char[] name;
	Type type;
	Class klass;
	void* address;
}
 
class Function { 
	// this name 'FQual' avoid a bug of dmd.
	enum FQual {
		STATIC = 0x01,
		DELEGATE = 0x02
	}
	FQual qual;
	Type ret;
	Type[] args;
}
 
class Builtin { 
	enum Type {
		BYTE, UBYTE, SHORT, USHORT, INT, UINT, LONG, ULONG, BIT,
		CHAR, WCHAR, DCHAR,
		FLOAT, DOUBLE, REAL, IFLOAT, IDOUBLE, IREAL,
		CFLOAT, CDOUBLE, CREAL, VOID,
		ARGS, ERR
	}
	Type type;

	static this() {
		simpleMangle['v'] = Type.VOID;
		simpleMangle['g'] = Type.BYTE;
		simpleMangle['h'] = Type.UBYTE;
		simpleMangle['s'] = Type.SHORT;
		simpleMangle['t'] = Type.USHORT;
		simpleMangle['i'] = Type.INT;
		simpleMangle['k'] = Type.UINT;
		simpleMangle['l'] = Type.LONG;
		simpleMangle['m'] = Type.ULONG;
		simpleMangle['f'] = Type.FLOAT;
		simpleMangle['d'] = Type.DOUBLE;
		simpleMangle['e'] = Type.REAL;

		simpleMangle['o'] = Type.IFLOAT;
		simpleMangle['p'] = Type.IDOUBLE;
		simpleMangle['j'] = Type.IREAL;
		simpleMangle['q'] = Type.CFLOAT;
		simpleMangle['r'] = Type.CDOUBLE;
		simpleMangle['c'] = Type.CREAL;

		simpleMangle['b'] = Type.BIT;
		simpleMangle['a'] = Type.CHAR;
		simpleMangle['u'] = Type.WCHAR;
		simpleMangle['w'] = Type.DCHAR;

		simpleMangle['@'] = Type.ERR;
	}

	this(Type t) { type = t; }
	this(char t) {
		if (! (t in simpleMangle)) {
			throw new Error("cannot demangle builtin symbol");
		}
		type = simpleMangle[t];
	}

	static Type[char] simpleMangle;
}
 
class Type { 
	enum Qual {
		ARRAY = 0x01,
		SARRAY = 0x02,
		ASSOC = 0x04,
		POINTER = 0x08,
		REFERENCE = 0x10,
		INOUT = 0x20,
		OUT = 0x40
	}
	Qual qual;
	Type assoc;
	enum Kind {
		UNKNOWN, BUILTIN, KLASS, FUNC
	}
	Kind kind;
	union {
		Builtin builtin;
		Class klass;
		Function func;
		char[] unknown;
	}

	char[] toString() {
		return "";
	}
}
  
// DebugInfo 
private:
	
enum{ 
	// Directory Entries

	IMAGE_DIRECTORY_ENTRY_EXPORT        =  0,   // Export Directory
	IMAGE_DIRECTORY_ENTRY_IMPORT        =  1,   // Import Directory
	IMAGE_DIRECTORY_ENTRY_RESOURCE      =  2,   // Resource Directory
	IMAGE_DIRECTORY_ENTRY_EXCEPTION     =  3,   // Exception Directory
	IMAGE_DIRECTORY_ENTRY_SECURITY      =  4,   // Security Directory
	IMAGE_DIRECTORY_ENTRY_BASERELOC     =  5,   // Base Relocation Table
	IMAGE_DIRECTORY_ENTRY_DEBUG         =  6,   // Debug Directory
	IMAGE_DIRECTORY_ENTRY_COPYRIGHT     =  7,   // Description String
	IMAGE_DIRECTORY_ENTRY_GLOBALPTR     =  8,   // Machine Value (MIPS GP)
	IMAGE_DIRECTORY_ENTRY_TLS           =  9,   // TLS Directory
	IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG   = 10,   // Load Configuration Directory
	IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT  = 11,   // Bound Import Directory in headers
	IMAGE_DIRECTORY_ENTRY_IAT           = 12,   // Import Address Table

	IMAGE_FILE_DEBUG_DIRECTORY				= 6,
	IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT		= 13,
	IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR	= 14,

	MAX_PATH                    = 260,
}
 
//include 
	
enum{ 
	sstModule			= 0x120,
	sstAlignSym 		= 0x125,
	sstSrcModule		= 0x127,
	sstLibraries		= 0x128,
	sstGlobalSym		= 0x129,
	sstGlobalPub		= 0x12a,
	sstGlobalTypes		= 0x12b,
	sstSegMap			= 0x12d,
	sstFileIndex		= 0x133,
	sstStaticSym		= 0x134,
// Old, crusty value
//	S_PUB32 			= 0x0203,
	S_PUB32 			= 0x1009,
}
 
/*
 * CodeView headers 
 */
	
struct OMFSignature 
{
	char		Signature[4];
	int			filepos;
}
 
struct OMFDirHeader 
{
	ushort	cbDirHeader;
	ushort	cbDirEntry;
	uint	cDir;
	int		lfoNextDir;
	uint	flags;
}
 
struct OMFDirEntry 
{
	ushort	SubSection;
	ushort	iMod;
	int		lfo;
	uint	cb;
}
  
/*
 * sstModule subsection 
 */
	
struct OMFSegDesc 
{
	ushort	Seg;
	ushort	pad;
	uint	Off;
	uint	cbSeg;
}
 
struct OMFModule 
{
	ushort	ovlNumber;
	ushort	iLib;
	ushort	cSeg;
	char			Style[2];
}
 
struct OMFModuleFull 
{
	ushort	ovlNumber;
	ushort	iLib;
	ushort	cSeg;
	char			Style[2];
	OMFSegDesc		*SegInfo;
	char			*Name;
}
  
/*
 * sstGlobalPub section 
 */
	
struct OMFSymHash 
{
	ushort	symhash;
	ushort	addrhash;
	uint	cbSymbol;
	uint	cbHSym;
	uint	cbHAddr;
}
 
struct DATASYM16 
{
		ushort reclen;	// Record length
		ushort rectyp;	// S_LDATA or S_GDATA
		int off;		// offset of symbol
		ushort seg;		// segment of symbol
		ushort typind;	// Type index
		byte name[1];	// Length-prefixed name
}
typedef DATASYM16 PUBSYM16;
 
// winnt.h 
	
struct IMAGE_DOS_HEADER 
{      // DOS .EXE header
    ushort   e_magic;                     // Magic number
    ushort   e_cblp;                      // Bytes on last page of file
    ushort   e_cp;                        // Pages in file
    ushort   e_crlc;                      // Relocations
    ushort   e_cparhdr;                   // Size of header in paragraphs
    ushort   e_minalloc;                  // Minimum extra paragraphs needed
    ushort   e_maxalloc;                  // Maximum extra paragraphs needed
    ushort   e_ss;                        // Initial (relative) SS value
    ushort   e_sp;                        // Initial SP value
    ushort   e_csum;                      // Checksum
    ushort   e_ip;                        // Initial IP value
    ushort   e_cs;                        // Initial (relative) CS value
    ushort   e_lfarlc;                    // File address of relocation table
    ushort   e_ovno;                      // Overlay number
    ushort   e_res[4];                    // Reserved words
    ushort   e_oemid;                     // OEM identifier (for e_oeminfo)
    ushort   e_oeminfo;                   // OEM information; e_oemid specific
    ushort   e_res2[10];                  // Reserved words
    int      e_lfanew;                    // File address of new exe header
}
 
struct IMAGE_FILE_HEADER 
{
    ushort    Machine;
    ushort    NumberOfSections;
    uint      TimeDateStamp;
    uint      PointerToSymbolTable;
    uint      NumberOfSymbols;
    ushort    SizeOfOptionalHeader;
    ushort    Characteristics;
}
 
struct IMAGE_SEPARATE_DEBUG_HEADER 
{
    ushort        Signature;
    ushort        Flags;
    ushort        Machine;
    ushort        Characteristics;
    uint       TimeDateStamp;
    uint       CheckSum;
    uint       ImageBase;
    uint       SizeOfImage;
    uint       NumberOfSections;
    uint       ExportedNamesSize;
    uint       DebugDirectorySize;
    uint       SectionAlignment;
    uint       Reserved[2];
}
 
struct IMAGE_DATA_DIRECTORY 
{
    uint   VirtualAddress;
    uint   Size;
}
 
enum{
	IMAGE_NUMBEROF_DIRECTORY_ENTRIES    = 16,
}
struct IMAGE_OPTIONAL_HEADER 
{
    //
    // Standard fields.
    //

    ushort    Magic;
    byte    MajorLinkerVersion;
    byte    MinorLinkerVersion;
    uint   SizeOfCode;
    uint   SizeOfInitializedData;
    uint   SizeOfUninitializedData;
    uint   AddressOfEntryPoint;
    uint   BaseOfCode;
    uint   BaseOfData;

    //
    // NT additional fields.
    //

    uint   ImageBase;
    uint   SectionAlignment;
    uint   FileAlignment;
    ushort    MajorOperatingSystemVersion;
    ushort    MinorOperatingSystemVersion;
    ushort    MajorImageVersion;
    ushort    MinorImageVersion;
    ushort    MajorSubsystemVersion;
    ushort    MinorSubsystemVersion;
    uint   Win32VersionValue;
    uint   SizeOfImage;
    uint   SizeOfHeaders;
    uint   CheckSum;
    ushort    Subsystem;
    ushort    DllCharacteristics;
    uint   SizeOfStackReserve;
    uint   SizeOfStackCommit;
    uint   SizeOfHeapReserve;
    uint   SizeOfHeapCommit;
    uint   LoaderFlags;
    uint   NumberOfRvaAndSizes;
    IMAGE_DATA_DIRECTORY DataDirectory[IMAGE_NUMBEROF_DIRECTORY_ENTRIES];
}
 
struct IMAGE_NT_HEADERS 
{
    uint Signature;
    IMAGE_FILE_HEADER FileHeader;
    IMAGE_OPTIONAL_HEADER OptionalHeader;
}
 
enum{
	IMAGE_SIZEOF_SHORT_NAME              = 8,
}

struct IMAGE_SECTION_HEADER 
{
    byte    Name[IMAGE_SIZEOF_SHORT_NAME];//8
    union misc{
            uint   PhysicalAddress;
            uint   VirtualSize;//12
    }
	misc Misc;
    uint   VirtualAddress;//16
    uint   SizeOfRawData;//20
    uint   PointerToRawData;//24
    uint   PointerToRelocations;//28
    uint   PointerToLinenumbers;//32
    ushort NumberOfRelocations;//34
    ushort NumberOfLinenumbers;//36
    uint   Characteristics;//40
}
 
struct IMAGE_DEBUG_DIRECTORY 
{
    uint   Characteristics;
    uint   TimeDateStamp;
    ushort MajorVersion;
    ushort MinorVersion;
    uint   Type;
    uint   SizeOfData;
    uint   AddressOfRawData;
    uint   PointerToRawData;
}
 
enum{ 
	IMAGE_DEBUG_TYPE_UNKNOWN          = 0,
	IMAGE_DEBUG_TYPE_COFF             = 1,
	IMAGE_DEBUG_TYPE_CODEVIEW         = 2,
	IMAGE_DEBUG_TYPE_FPO              = 3,
	IMAGE_DEBUG_TYPE_MISC             = 4,
	IMAGE_DEBUG_TYPE_EXCEPTION        = 5,
	IMAGE_DEBUG_TYPE_FIXUP            = 6,
	IMAGE_DEBUG_TYPE_OMAP_TO_SRC      = 7,
	IMAGE_DEBUG_TYPE_OMAP_FROM_SRC    = 8,

}
   
/*
 * sstSrcModule section 
 */
	
struct OMFSourceLine 
{
	ushort	Seg;
	ushort	cLnOff;
	uint	offset[1];
	ushort	lineNbr[1];
}
 
struct OMFSourceFile 
{
	ushort	cSeg;
	ushort	reserved;
	uint	baseSrcLn[1];
	ushort	cFName;
	char	Name;
}
 
struct OMFSourceModule 
{
	ushort	cFile;
	ushort	cSeg;
	uint	baseSrcFile[1];
}
   
public class DebugInfo 
{
	
private: 

typedef int CVHeaderType ;
enum :CVHeaderType{ CV_NONE, CV_DOS, CV_NT, CV_DBG }

int g_dwStartOfCodeView = 0; // R[hr[Jnʒu

bool g_exe_mode = true;
IMAGE_DOS_HEADER g_doshdr;
IMAGE_SEPARATE_DEBUG_HEADER g_dbghdr;
IMAGE_NT_HEADERS g_nthdr;

IMAGE_SECTION_HEADER g_secthdrs[];

IMAGE_DEBUG_DIRECTORY g_debugdirs[];
OMFSignature g_cvSig;
OMFDirHeader g_cvHeader;
OMFDirEntry g_cvEntries[];
OMFModuleFull g_cvModules[];
char[] g_filename;

void*[char[]] sym2addr;
ushort[uint] addr2line;
ushort[][char[]] file2lines;
 
public void*[char[]] getSymToAddr(){ 
	return sym2addr;
}
public ushort[uint] getAddrToLine(){
	return addr2line;
}
public ushort[][char[]] getFileToLines(){
	return file2lines;
}
 
public this(char[] filename) 
{
	DumpCVFile(filename);
}
 
private:

int DumpCVFile (char[] filename) 
{
	File debugfile;

	if (filename == "") return (-1);

	try{
		debugfile = new File(filename, FileMode.In);
	}catch(Exception e){
		return -1;
	}

	if (!DumpFileHeaders (debugfile)) return -1;

	g_secthdrs.length = g_nthdr.FileHeader.NumberOfSections;

	if (!DumpSectionHeaders (debugfile)) return -1;

	g_debugdirs.length = g_nthdr.OptionalHeader.DataDirectory[IMAGE_FILE_DEBUG_DIRECTORY].Size /
		IMAGE_DEBUG_DIRECTORY.sizeof;

	if (!DumpDebugDir (debugfile)) return -1;
	if (g_dwStartOfCodeView == 0) return -1;
	if (!DumpCodeViewHeaders (debugfile)) return -1;
	if (!DumpAllModules (debugfile)) return -1;

	g_dwStartOfCodeView = 0; // R[hr[Jnʒu
	g_exe_mode = true;
	g_secthdrs = null;
	g_debugdirs = null;
	g_cvEntries = null;
	g_cvModules = null;
	g_filename = null;

	debugfile.close();
	return 0;
}
	
bool DumpFileHeaders (File debugfile) 
{
	CVHeaderType hdrtype;

	hdrtype = GetHeaderType (debugfile);

	if (hdrtype == CV_DOS) {
		if (!ReadDOSFileHeader (debugfile, &g_doshdr))return false;
		hdrtype = GetHeaderType (debugfile);
	}
	if (hdrtype == CV_NT) {
		if (!ReadPEFileHeader (debugfile, &g_nthdr)) return false;
	}

	return true;
}
	
CVHeaderType GetHeaderType (File debugfile)// PE・＝ACV_NTﾔす。 
{
	ushort hdrtype;
	CVHeaderType ret = CV_NONE;

	int oldpos = cast(int)debugfile.position();

	if (!ReadChunk (debugfile, &hdrtype, ushort.sizeof, -1)){
		debugfile.seekSet(oldpos);
		return CV_NONE;
	}

	if (hdrtype == 0x5A4D) 	     // "MZ"
		ret = CV_DOS;
	else if (hdrtype == 0x4550)  // "PE"
		ret = CV_NT;
	else if (hdrtype == 0x4944)  // "DI"
		ret = CV_DBG;

	debugfile.seekSet(oldpos);

	return ret;
}
 
/*
 * Extract the DOS file headers from an executable
 */
bool ReadDOSFileHeader (File debugfile, IMAGE_DOS_HEADER *doshdr) 
{
	uint bytes_read;

	bytes_read = debugfile.readBlock(doshdr, IMAGE_DOS_HEADER.sizeof);
	if (bytes_read < IMAGE_DOS_HEADER.sizeof){
		return false;
	}

	// Skip over stub data, if present
	if (doshdr.e_lfanew)
		debugfile.seekSet(doshdr.e_lfanew);

	return true;
}
 
/*
 * Extract the DOS and NT file headers from an executable
 */
bool ReadPEFileHeader (File debugfile, IMAGE_NT_HEADERS *nthdr) 
{
	uint bytes_read;

	bytes_read = debugfile.readBlock (nthdr, IMAGE_NT_HEADERS.sizeof );
	if (bytes_read < IMAGE_NT_HEADERS.sizeof) {
		return false;
	}

	return true;
}
  
bool DumpSectionHeaders (File debugfile) 
{
	if (!ReadSectionHeaders (debugfile, g_secthdrs)) return false;
	return true;
}
	
bool ReadSectionHeaders (File debugfile, inout IMAGE_SECTION_HEADER[] secthdrs) 
{
	for(int i=0;i<secthdrs.length;i++){
		uint bytes_read;
		bytes_read = debugfile.readBlock(&secthdrs[i],  IMAGE_SECTION_HEADER.sizeof);
		if (bytes_read < 1){
			return false;
		}
	}
	return true;
}
  
bool DumpDebugDir (File debugfile) 
{
	int i;
	int filepos;

	if (g_debugdirs.length == 0) return false;

	filepos = GetOffsetFromRVA (g_nthdr.OptionalHeader.DataDirectory[IMAGE_FILE_DEBUG_DIRECTORY].VirtualAddress);

	debugfile.seekSet(filepos);

	if (!ReadDebugDir (debugfile, g_debugdirs)) return false;

	for (i = 0; i < g_debugdirs.length; i++) {
		if (g_debugdirs[i].Type == IMAGE_DEBUG_TYPE_CODEVIEW) {
			g_dwStartOfCodeView = g_debugdirs[i].PointerToRawData;
		}
	}

	g_debugdirs = null;

	return true;
}
	
// Calculate the file offset, based on the RVA.
uint GetOffsetFromRVA (uint rva) 
{
	int i;
	uint sectbegin;

	for (i = g_secthdrs.length - 1; i >= 0; i--) {
		sectbegin = g_secthdrs[i].VirtualAddress;
		if (rva >= sectbegin) break;
	}
	uint offset = g_secthdrs[i].VirtualAddress - g_secthdrs[i].PointerToRawData;
	uint filepos = rva - offset;
	return filepos;
}
 
// Load in the debug directory table.  This directory describes the various
// blocks of debug data that reside at the end of the file (after the COFF
// sections), including FPO data, COFF-style debug info, and the CodeView
// we are *really* after.
bool ReadDebugDir (File debugfile, inout IMAGE_DEBUG_DIRECTORY debugdirs[]) 
{
	uint bytes_read;
	for(int i=0;i<debugdirs.length;i++) {
		bytes_read = debugfile.readBlock (&debugdirs[i], IMAGE_DEBUG_DIRECTORY.sizeof);
		if (bytes_read < IMAGE_DEBUG_DIRECTORY.sizeof) {
			return false;
		}
	}
	return true;
}
  
bool DumpCodeViewHeaders (File debugfile) 
{
	debugfile.seekSet(g_dwStartOfCodeView);
	if (!ReadCodeViewHeader (debugfile, g_cvSig, g_cvHeader)) return false;
	g_cvEntries.length = g_cvHeader.cDir;
	if (!ReadCodeViewDirectory (debugfile, g_cvEntries)) return false;
	return true;
}

	
bool ReadCodeViewHeader (File debugfile, out OMFSignature sig, out OMFDirHeader dirhdr) 
{
	uint bytes_read;

	bytes_read = debugfile.readBlock(&sig, OMFSignature.sizeof );
	if (bytes_read < OMFSignature.sizeof){
		return false;
	}

	debugfile.seekSet(sig.filepos + g_dwStartOfCodeView);
	bytes_read = debugfile.readBlock(&dirhdr,OMFDirHeader.sizeof);
	if (bytes_read < OMFDirHeader.sizeof){
		return false;
	}
	return true;
}
 
bool ReadCodeViewDirectory (File debugfile, inout OMFDirEntry[] entries) 
{
	uint bytes_read;

	for(int i=0;i<entries.length;i++){
		bytes_read = debugfile.readBlock(&entries[i], OMFDirEntry.sizeof);
		if (bytes_read < OMFDirEntry.sizeof){
			return false;
		}
	}
	return true;
}
  
bool DumpAllModules (File debugfile) 
{
	if (g_cvHeader.cDir == 0){
		return true;
	}

	if (g_cvEntries.length == 0){
		return false;
	}

	debugfile.seekSet(g_dwStartOfCodeView + g_cvEntries[0].lfo);

	if (!ReadModuleData (debugfile, g_cvEntries, g_cvModules)){
		return false;
	}


	for (int i = 0; i < g_cvModules.length; i++){
		DumpRelatedSections (i, debugfile);
	}

	for (int i = 0; i < g_cvHeader.cDir; i++){
		DumpMiscSections (i, debugfile);
	}

	return true;
}

	
bool ReadModuleData (File debugfile, OMFDirEntry[] entries, out OMFModuleFull[] modules) 
{
	uint bytes_read;
	int pad;

	int module_bytes = (ushort.sizeof * 3) + (char.sizeof * 2);

	if (entries == null) return false;

	modules.length = 0;

	for (int i = 0; i < entries.length; i++){
		if (entries[i].SubSection == sstModule)
			modules.length = modules.length + 1;
	}

	for (int i = 0; i < modules.length; i++){

		bytes_read = debugfile.readBlock(&modules[i],module_bytes);
		if (bytes_read < module_bytes){
			return false;
		}

		int segnum = modules[i].cSeg;
		OMFSegDesc[] segarray;
		segarray.length=segnum;
		for(int j=0;j<segnum;j++){
			bytes_read =  debugfile.readBlock(&segarray[j], OMFSegDesc.sizeof);
			if (bytes_read < OMFSegDesc.sizeof){
				return false;
			}
		}
		modules[i].SegInfo = segarray;

		char namelen;
		bytes_read = debugfile.readBlock(&namelen, char.sizeof);
		if (bytes_read < 1){
			return false;
		}

		pad = ((namelen + 1) % 4);
		if (pad) namelen += (4 - pad);

		modules[i].Name = new char[namelen+1];
		modules[i].Name[namelen]=0;
		bytes_read = debugfile.readBlock(modules[i].Name, namelen);
		if (bytes_read < namelen){
			return false;
		}
	}
	return true;
}
 
bool DumpRelatedSections (int index, File debugfile) 
{
	int i;

	if (g_cvEntries == null)
		return false;

	for (i = 0; i < g_cvHeader.cDir; i++){
		if (g_cvEntries[i].iMod != (index + 1) ||
			g_cvEntries[i].SubSection == sstModule)
			continue;

		switch (g_cvEntries[i].SubSection){
		case sstSrcModule:
			DumpSrcModuleInfo (i, debugfile);
			break;
		default:
			break;
		}
	}

	return true;
}
	
bool DumpSrcModuleInfo (int index, File debugfile) 
{
	int i;

	byte *rawdata;
	byte *curpos;
	short filecount;
	short segcount;

	int moduledatalen;
	int filedatalen;
	int linedatalen;

	if (g_cvEntries == null || debugfile == null ||
		g_cvEntries[index].SubSection != sstSrcModule)
		return false;

	int fileoffset = g_dwStartOfCodeView + g_cvEntries[index].lfo;

	rawdata = new byte[g_cvEntries[index].cb];
	if (!rawdata) return false;

	if (!ReadChunk (debugfile, rawdata, g_cvEntries[index].cb, fileoffset)) return false;
	uint[] baseSrcFile;
	PrintSrcModuleInfo (rawdata, &filecount, &segcount,baseSrcFile);

	for(int i=0;i<baseSrcFile.length;i++){
		uint baseSrcLn[];
		PrintSrcModuleFileInfo (rawdata+baseSrcFile[i],baseSrcLn);
		for(int j=0;j<baseSrcLn.length;j++){
			PrintSrcModuleLineInfo (rawdata+baseSrcLn[j], j);
		}
	}

	return true;
}
	
void PrintSrcModuleInfo (byte* rawdata, short *filecount, short *segcount,out uint[] fileinfopos) 
{
	int i;
	int datalen;

	ushort cFile;
	ushort cSeg;
	uint *baseSrcFile;
	uint *segarray;
	ushort *segindexarray;

	cFile = *cast(ushort*)rawdata;
	cSeg = *cast(ushort*)(rawdata + 2);
	baseSrcFile = cast(uint*)(rawdata + 4);
	segarray = &baseSrcFile[cFile];
	segindexarray = cast(ushort*)(&segarray[cSeg * 2]);

	*filecount = cast(short)cFile;
	*segcount = cast(short)cSeg;

	fileinfopos.length=cFile;
	for (i = 0; i < cFile; i++){
		fileinfopos[i]=baseSrcFile[i];
	}

}
 
void PrintSrcModuleFileInfo (byte* rawdata,out uint[] offset) 
{
	int i;
	int datalen;

	ushort cSeg;
	uint *baseSrcLn;
	uint *segarray;
	byte cFName;

	cSeg = *cast(ushort*)(rawdata);
	// Skip the 'pad' field
	baseSrcLn = cast(uint*)(rawdata + 4);
	segarray = &baseSrcLn[cSeg];
	cFName = *(cast(byte*)&segarray[cSeg*2]);

	g_filename=(cast(char*)&segarray[cSeg*2] + 1)[0..cFName].dup;

	offset.length=cSeg;
	for (i = 0; i < cSeg; i++){
		offset[i]=baseSrcLn[i];
	}
}
 
void PrintSrcModuleLineInfo (byte* rawdata, int tablecount) 
{
	int i;

	ushort Seg;
	ushort cPair;
	uint *offset;
	ushort *linenumber;

	Seg = *cast(ushort*)rawdata;
	cPair = *cast(ushort*)(rawdata + 2);
	offset = cast(uint*)(rawdata + 4);
	linenumber = cast(ushort*)&offset[cPair];

	uint base=0;
	if(Seg!=0){
		base = g_nthdr.OptionalHeader.ImageBase+g_secthdrs[Seg-1].VirtualAddress;
	}
	for (i = 0; i < cPair; i++){
		uint address = offset[i]+base;
		//writefln ("%.*s:%08lx line(%d)", g_filename, address, linenumber[i]);
		//g_addressData[address].filename=g_filename;
		//g_addressData[address].line=linenumber[i];
		file2lines[g_filename] ~= linenumber[i];
		addr2line[address]=linenumber[i];
	}

}
   
bool DumpMiscSections (int index, File debugfile) 
{

	if (g_cvEntries == null || g_cvEntries[index].iMod != 65535)
		return false;

	switch (g_cvEntries[index].SubSection){
	case sstGlobalPub:
		DumpGlobalPubInfo (index, debugfile);
		break;
	default:
		break;
	}

	return true;
}
	
bool DumpGlobalPubInfo (int index, File debugfile) 
{
	int fileoffset;
	uint sectionsize;
	OMFSymHash header;
	byte *symbols;
	byte *curpos;
	PUBSYM16 *sym;
	char symlen;
	char *symname;
	int recordlen;

	if (g_cvEntries == null || debugfile == null ||
		g_cvEntries[index].SubSection != sstGlobalPub)
		return false;

	sectionsize = g_cvEntries[index].cb;

	fileoffset = g_dwStartOfCodeView + g_cvEntries[index].lfo;

	//writefln ("  (type)      (symbol name)                (address)      (len) (seg) (ind)");

	if (!ReadChunk (debugfile, &header, OMFSymHash.sizeof, fileoffset))
		return false;

	symbols = new byte[header.cbSymbol];
	if (!ReadChunk (debugfile, symbols, header.cbSymbol, -1))
		return false;

	curpos = symbols;
//	auto Demangle demangler = new Demangle();
	while (curpos < symbols + header.cbSymbol){
		char[] nametmp;	// Zero out
		sym = cast(PUBSYM16*)curpos;
		symlen = *(curpos + PUBSYM16.sizeof-1);
		symname = cast(char*)((curpos + PUBSYM16.sizeof-1)+1);
		nametmp = symname[0..(symlen&0xff)].dup;

		int base=0;
		if(sym.seg!=0){
			base = g_nthdr.OptionalHeader.ImageBase+g_secthdrs[sym.seg-1].VirtualAddress;
		}
		if(nametmp.length!=0 && nametmp[0]!=0){
			// "  (type) (symbol name)        (address)   (len) (seg) (typind)"
			// writefln ("  0x%04x  %-30.30s  [0x%8lx]  [0x%4x]  %d     %ld %d",
			//		sym.rectyp, toStringz(nametmp), base+sym.off, sym.reclen, sym.seg, sym.typind, nametmp.length);
			//g_addressData[base+sym.off].name=nametmp;
//			char[] name = demangler.demangleName(nametmp).join(".");
//			if(name=="")
				sym2addr[nametmp]=cast(void*)(base+sym.off);
//			else
//				sym2addr[name]=cast(void*)(base+sym.off);
		}
		recordlen = sym.reclen;
		if (recordlen % 4) recordlen += 4 - (recordlen % 4);

		curpos += recordlen;
	}

	return true;
}
   
bool ReadChunk (File debugfile, void *dest, int length, int fileoffset) 
{
	uint bytes_read;

	if (fileoffset >= 0) debugfile.seekSet(fileoffset);

	bytes_read = debugfile.readBlock (dest,length);
	if (bytes_read < length) {
		return false;
	}

	return true;
}

  
} 
  
/+ 
int main(char[][] argv)
{
	DebugInfo di = new DebugInfo(argv[0]);
	void*[char[]] sym2addr = di.getSymToAddr();
	ushort[uint] addr2line = di.getAddrToLine();
	ushort[][char[]] file2lines = di.getFileToLines();

	char[][uint] addr2sym;
	foreach(char[] sym,void* addr;sym2addr){
		// writefln("addr %08x %.*s",addr,sym);
		addr2sym[cast(int)addr]=sym;
	}
	void*[ushort] line2addr;
	foreach(uint addr,ushort line;addr2line){
		// writefln("addr %08x line %d",addr,line);
		line2addr[line]=cast(void*)addr;
	}

	foreach(char[] file,ushort[] lines;file2lines){
		writefln("%.*s----------",file);
		char[] sym;
		foreach(ushort line;lines){
			uint addr = cast(uint)line2addr[line];
			char[] sym1 = addr2sym[addr];
			if(sym1!="")sym=sym1;
			writefln("%.*s %.*s:%08x (%d)",sym,file,addr,line);
		}
	}
	return 0;
}
+/
  
