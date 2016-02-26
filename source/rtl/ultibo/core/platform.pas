{
Ultibo Platform interface unit.

Copyright (C) 2015 - SoftOz Pty Ltd.

Arch
====

 <All>

Boards
======

 <All>

Licence
=======

 LGPLv2.1 with static linking exception (See COPYING.modifiedLGPL.txt)
 
Credits
=======

 Information for this unit was obtained from:

 
References
==========


Platform
========


}

{$mode delphi} {Default to Delphi compatible syntax}
{$H+}          {Default to AnsiString}
{$inline on}   {Allow use of Inline procedures}

unit Platform; 

interface

uses GlobalConfig,GlobalConst,GlobalTypes,GlobalStrings,HeapManager,SysUtils;

{==============================================================================}
{Global definitions}
{$INCLUDE GlobalDefines.inc}

{==============================================================================}
{Text IO definitions}
{$INCLUDE ..\..\inc\TextRec.inc} {Note: Temporary include with path until change to Ultibo specific target}

{==============================================================================}
const
 {Platform specific constants}

 {Page Table Flags}
 PAGE_TABLE_FLAG_NONE          = (1 shl 0);
 PAGE_TABLE_FLAG_NORMAL        = (1 shl 1);
 PAGE_TABLE_FLAG_DEVICE        = (1 shl 2);
 PAGE_TABLE_FLAG_ORDERED       = (1 shl 3);
 PAGE_TABLE_FLAG_SHARED        = (1 shl 4);
 PAGE_TABLE_FLAG_CACHEABLE     = (1 shl 5);
 PAGE_TABLE_FLAG_READONLY      = (1 shl 6);
 PAGE_TABLE_FLAG_READWRITE     = (1 shl 7);
 PAGE_TABLE_FLAG_EXECUTABLE    = (1 shl 8);
 PAGE_TABLE_FLAG_WRITEBACK     = (1 shl 9);
 PAGE_TABLE_FLAG_WRITETHROUGH  = (1 shl 10);
 PAGE_TABLE_FLAG_WRITEALLOCATE = (1 shl 11);
 
 {Exception Types}
 EXCEPTION_TYPE_DATA_ABORT            = 1;
 EXCEPTION_TYPE_PREFETCH_ABORT        = 2;
 EXCEPTION_TYPE_UNDEFINED_INSTRUCTION = 3;
 
 {Platform logging}
 PLATFORM_LOG_LEVEL_DEBUG     = LOG_LEVEL_DEBUG;  {Platform debugging messages}
 PLATFORM_LOG_LEVEL_INFO      = LOG_LEVEL_INFO;   {Platform informational messages}
 PLATFORM_LOG_LEVEL_ERROR     = LOG_LEVEL_ERROR;  {Platform error messages}
 PLATFORM_LOG_LEVEL_NONE      = LOG_LEVEL_NONE;   {No Platform messages}

var 
 PLATFORM_DEFAULT_LOG_LEVEL:LongWord = PLATFORM_LOG_LEVEL_INFO; {Minimum level for Platform messages.  Only messages with level greater than or equal to this will be printed}
 
var 
 {Platform logging}
 PLATFORM_LOG_ENABLED:Boolean; 

{==============================================================================}
const
 {IRQ specific constants}
 
 {IRQ logging}
 IRQ_LOG_LEVEL_DEBUG     = LOG_LEVEL_DEBUG;  {IRQ debugging messages}
 IRQ_LOG_LEVEL_INFO      = LOG_LEVEL_INFO;   {IRQ informational messages}
 IRQ_LOG_LEVEL_ERROR     = LOG_LEVEL_ERROR;  {IRQ error messages}
 IRQ_LOG_LEVEL_NONE      = LOG_LEVEL_NONE;   {No IRQ messages}

var 
 IRQ_DEFAULT_LOG_LEVEL:LongWord = IRQ_LOG_LEVEL_INFO; {Minimum level for IRQ messages.  Only messages with level greater than or equal to this will be printed} 
 
var 
 {IRQ logging}
 IRQ_LOG_ENABLED:Boolean; 

{==============================================================================}
const
 {FIQ specific constants}
 
 {FIQ logging}
 FIQ_LOG_LEVEL_DEBUG     = LOG_LEVEL_DEBUG;  {FIQ debugging messages}
 FIQ_LOG_LEVEL_INFO      = LOG_LEVEL_INFO;   {FIQ informational messages}
 FIQ_LOG_LEVEL_ERROR     = LOG_LEVEL_ERROR;  {FIQ error messages}
 FIQ_LOG_LEVEL_NONE      = LOG_LEVEL_NONE;   {No FIQ messages}

var 
 FIQ_DEFAULT_LOG_LEVEL:LongWord = FIQ_LOG_LEVEL_INFO; {Minimum level for FIQ messages.  Only messages with level greater than or equal to this will be printed}
 
var 
 {FIQ logging}
 FIQ_LOG_ENABLED:Boolean; 

{==============================================================================}
const
 {SWI specific constants}
 
 {SWI logging}
 SWI_LOG_LEVEL_DEBUG     = LOG_LEVEL_DEBUG;  {SWI debugging messages}
 SWI_LOG_LEVEL_INFO      = LOG_LEVEL_INFO;   {SWI informational messages}
 SWI_LOG_LEVEL_ERROR     = LOG_LEVEL_ERROR;  {SWI error messages}
 SWI_LOG_LEVEL_NONE      = LOG_LEVEL_NONE;   {No SWI messages}

var 
 SWI_DEFAULT_LOG_LEVEL:LongWord = SWI_LOG_LEVEL_INFO; {Minimum level for SWI messages.  Only messages with level greater than or equal to this will be printed}
 
var 
 {SWI logging}
 SWI_LOG_ENABLED:Boolean; 
 
{==============================================================================}
type
 {Platform specific types}

 {IRQ/FIQ Masks}
 TIRQMask = LongWord;
 TFIQMask = LongWord; 
 TIRQFIQMask = LongWord;
 
 {Abort Masks}
 TAbortMask = LongWord;

type
 {SWI Request}
 PSWIRequest = ^TSWIRequest;
 TSWIRequest = record
  Number:LongWord;
  Param1:LongWord;
  Param2:LongWord;
  Param3:LongWord;
 end; 
 
type 
 {Handle Entry}
 PHandleEntry = ^THandleEntry;
 THandleEntry = record
  {Handle Properties}
  Signature:LongWord;             {Signature for entry validation}
  HandleType:LongWord;            {Type of this Handle (eg HANDLE_TYPE_THREAD)}
  HandleCount:LongWord;           {Reference Count of the Handle}
  {Internal Properties}
  Prev:PHandleEntry;              {Previous entry in Handle table}
  Next:PHandleEntry;              {Next entry in Handle table}
  {Statistics Properties}
 end;
 
 //THandleList //To Do 
 
type
 {Shutdown Entry}
 PShutdownEntry = ^TShutdownEntry;
 TShutdownEntry = record
  {Shutdown Properties}
  Signature:LongWord;                    {Signature for entry validation}
  Shutdown:procedure(Parameter:Pointer); {The procedure to call on Shutdown}
  Parameter:Pointer;                     {The parameter to pass to the Shutdown procedure (or nil)}
  {Internal Properties}
  Prev:PShutdownEntry;                   {Previous entry in Shutdown table}
  Next:PShutdownEntry;                   {Next entry in Shutdown table}
 end; 
 
type 
 {Interrupt Entry (IRQ/FIQ/SWI}
 PInterruptEntry = ^TInterruptEntry;
 TInterruptEntry = record
  Number:LongWord;
  CPUID:LongWord;
  Handler:procedure(Parameter:Pointer);
  HandlerEx:function(CPUID:LongWord;Thread:TThreadHandle;Parameter:Pointer):TThreadHandle;
  Parameter:Pointer;
 end;
 
type
 {Page Table Entry}
 PPageTableEntry = ^TPageTableEntry;
 TPageTableEntry = record
  VirtualAddress:PtrUInt;
  PhysicalAddress:PtrUInt;
  Size:LongWord;
  Flags:LongWord;
 end;

type
 {Platform Lock}
 PPlatformLock = ^TPlatformLock;
 TPlatformLock = record
  Lock:THandle; 
  AcquireLock:function(Handle:THandle):LongWord;
  ReleaseLock:function(Handle:THandle):LongWord;
 end;
 
type
 {Platform Semaphore}
 PPlatformSemaphore = ^TPlatformSemaphore;
 TPlatformSemaphore = record
  Semaphore:THandle;
  WaitSemaphore:function(Handle:THandle):LongWord;
  SignalSemaphore:function(Handle:THandle):LongWord;
 end; 
 
type
 {Prototypes for Initialization Handlers}
 TCPUInit = procedure;
 TFPUInit = procedure;
 TGPUInit = procedure;
 TMMUInit = procedure;
 TSMPInit = procedure;
 TCacheInit = procedure;
 TBoardInit = procedure;
 TMemoryInit = procedure;
 TClockInit = procedure;
 TPowerInit = procedure;
 TMailboxInit = procedure;
 TInterruptInit = procedure;
 TPeripheralInit = procedure;
 {$IFDEF CONSOLE_EARLY_INIT}
 TFramebufferInit = procedure;
 {$ENDIF}
 
 TParseBootTags = procedure;
 TParseCommandLine = procedure;
 TParseEnvironment = procedure;

type
 {Prototype for Interrupt Handlers}
 TInterruptHandler = procedure(Parameter:Pointer);
 TInterruptExHandler = function(CPUID:LongWord;Thread:TThreadHandle;Parameter:Pointer):TThreadHandle; 
 
type
 {Prototypes for Thread Yield/Wait/Release/Abandon Handlers}
 TThreadYield = function:LongWord;
 TThreadWait = function(List:TListHandle;Lock:TSpinHandle;Flags:LongWord):LongWord;
 TThreadWaitEx = function(List:TListHandle;Lock:TSpinHandle;Flags,Timeout:LongWord):LongWord;
 TThreadRelease = function(List:TListHandle):LongWord;
 TThreadAbandon = function(List:TListHandle):LongWord;

type 
 {Prototypes for Thread Wake/Ready/Timeout Handlers}
 TThreadWake = function(Thread:TThreadHandle):LongWord;
 TThreadReady = function(Thread:TThreadHandle;Reschedule:Boolean):LongWord;
 TThreadTimeout = function(Thread:TThreadHandle):LongWord;
 
type
 {Prototype for Timer Event Handler}
 TTimerEvent = procedure(Data:Pointer);

type
 {Prototype for Worker Task/Callback Handlers}
 TWorkerTask = procedure(Data:Pointer); 
 TWorkerCallback = procedure(Data:Pointer); 

type 
 {Prototype for GPIO Event Handlers}
 TGPIOEvent = procedure(Data:Pointer);
 
type
 {Prototypes for Blink Handlers}
 TBootBlink = procedure;
 
type
 {Prototypes for LED Handlers}
 TPowerLEDEnable = procedure;
 TPowerLEDOn = procedure;
 TPowerLEDOff = procedure;
 
 TActivityLEDEnable = procedure;
 TActivityLEDOn = procedure;
 TActivityLEDOff = procedure;
 
type
 {Prototypes for Mailbox Handlers}
 TMailboxReceive = function(Mailbox,Channel:LongWord):LongWord;
 TMailboxSend = procedure(Mailbox,Channel,Data:LongWord);

 TMailboxCall = function(Mailbox,Channel,Data:LongWord;var Response:LongWord):LongWord;
 TMailboxCallEx = function(Mailbox,Channel,Data:LongWord;var Response:LongWord;Timeout:LongWord):LongWord;
 TMailboxPropertyCall = function(Mailbox,Channel:LongWord;Data:Pointer;var Response:LongWord):LongWord;
 TMailboxPropertyCallEx = function(Mailbox,Channel:LongWord;Data:Pointer;var Response:LongWord;Timeout:LongWord):LongWord;

type
 {Prototypes for Random Handlers}
 TRandomAvailable = function:Boolean;
 
 TRandomSeed = procedure(Seed:LongWord);

 TRandomReadLongInt = function(Limit:LongInt):LongInt;
 TRandomReadInt64 = function(Limit:Int64):Int64;
 TRandomReadExtended = function:Extended;

type
 {Prototypes for Watchdog Handlers}
 TWatchdogAvailable = function:Boolean;
 
 TWatchdogStart = function(Milliseconds:LongWord):LongWord; 
 TWatchdogStop = function:LongWord;
 TWatchdogRefresh = function(Milliseconds:LongWord):LongWord;
 
type 
 {Prototypes for Interrupt Request (IRQ) Handlers}
 TRequestIRQ = function(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord;
 TReleaseIRQ = function(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord;
 TRequestExIRQ = function(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord;
 TReleaseExIRQ = function(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord;
 
type
 {Prototypes for Fast Interrupt Request (FIQ) Handlers}
 TRequestFIQ = function(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord;
 TReleaseFIQ = function(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord;
 TRequestExFIQ = function(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord;
 TReleaseExFIQ = function(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord;
 
type
 {Prototypes for System Handlers}
 TSystemRestart = function(Delay:LongWord):LongWord; 
 TSystemShutdown = function(Delay:LongWord):LongWord;
 TSystemGetUptime = function:Int64;
 TSystemGetCommandLine = function:String;
 TSystemGetEnvironment = function:Pointer;
 TSystemCall = procedure(Number:LongWord;Param1,Param2,Param3:PtrUInt);
 
type
 {Prototypes for CPU Handlers}
 TCPUGetType = function:LongWord;
 TCPUGetBoot = function:LongWord;
 TCPUGetMask = function:LongWord;
 TCPUGetCount = function:LongWord;
 TCPUGetMode = function:LongWord;
 TCPUGetState = function:LongWord;
 TCPUGetCurrent = function:LongWord;
 TCPUGetMemory = function(var Address:PtrUInt;var Length:LongWord):LongWord;
 TCPUGetPercentage = function(CPUID:LongWord):Double;
 TCPUGetUtilization = function(CPUID:LongWord):LongWord;
 
 TCPUGetModel = function:LongWord;
 TCPUGetRevision = function:LongWord;
 TCPUGetDescription = function:String;
 
type
 {Prototypes for FPU Handlers}
 TFPUGetType = function:LongWord;
 TFPUGetState = function:LongWord;

type
 {Prototypes for GPU Handlers}
 TGPUGetType = function:LongWord;
 TGPUGetState = function:LongWord;
 TGPUGetMemory = function(var Address:PtrUInt;var Length:LongWord):LongWord;
 
type
 {Prototypes for Cache Handlers}
 TL1CacheGetType = function:LongWord;
 TL1DataCacheGetSize = function:LongWord;
 TL1DataCacheGetLineSize = function:LongWord;
 TL1InstructionCacheGetSize = function:LongWord;
 TL1InstructionCacheGetLineSize = function:LongWord;
 
 TL2CacheGetType = function:LongWord;
 TL2CacheGetSize = function:LongWord;
 TL2CacheGetLineSize = function:LongWord;
 
type
 {Prototypes for Board Handlers}
 TBoardGetType = function:LongWord;
 TBoardGetModel = function:LongWord;
 TBoardGetSerial = function:Int64;
 TBoardGetRevision = function:LongWord;
 TBoardGetMACAddress = function:String;
 
type
 {Prototypes for Firmware Handlers}
 TFirmwareGetRevision = function:LongWord;
 
type
 {Prototypes for Machine Handlers}
 TMachineGetType = function:LongWord;
 
type
 {Prototypes for Memory Handlers}
 TMemoryGetBase = function:PtrUInt;
 TMemoryGetSize = function:LongWord;

 TMemoryGetPageSize = function:LongWord;
 TMemoryGetLargePageSize = function:LongWord;
 
type
 {Prototypes for Power Handlers}
 TPowerGetWait = function(PowerId:LongWord):LongWord;
 TPowerGetState = function(PowerId:LongWord):LongWord;
 TPowerSetState = function(PowerId,State:LongWord;Wait:Boolean):LongWord;
 
type
 {Prototypes for Clock Handlers}
 TClockGetCount = function:LongWord; 
 TClockGetTotal = function:Int64; 
 
 TClockUpdateOffset = function:LongWord;
 
 TClockGetRate = function(ClockId:LongWord):LongWord;
 TClockSetRate = function(ClockId,Rate:LongWord;Turbo:Boolean):LongWord;
 TClockGetState = function(ClockId:LongWord):LongWord;
 TClockSetState = function(ClockId,State:LongWord):LongWord;
 TClockGetMinRate = function(ClockId:LongWord):LongWord;
 TClockGetMaxRate = function(ClockId:LongWord):LongWord;
 
type
 {Prototypes for Turbo Handlers}
 TTurboGetState = function(TurboId:LongWord):LongWord;
 TTurboSetState = function(TurboId,State:LongWord):LongWord;

type
 {Prototypes for Voltage Handlers}
 TVoltageGetValue = function (VoltageId:LongWord):LongWord;
 TVoltageSetValue = function (VoltageId,Value:LongWord):LongWord;

 TVoltageGetMinValue = function(VoltageId:LongWord):LongWord;
 TVoltageGetMaxValue = function(VoltageId:LongWord):LongWord;
 
type
 {Prototypes for Temperature Handlers}
 TTemperatureGetCurrent = function(TemperatureId:LongWord):LongWord;
 TTemperatureGetMaximum = function(TemperatureId:LongWord):LongWord;
 
type
 {Prototypes for GPU Memory Handlers}
 TGPUMemoryAllocate = function(Length,Alignment,Flags:LongWord):THandle;
 TGPUMemoryRelease = function(Handle:THandle):LongWord;
 TGPUMemoryLock = function(Handle:THandle):LongWord;
 TGPUMemoryUnlock = function(Handle:THandle):LongWord;

type
 {Prototypes for GPU Misc Handlers}
 TGPUExecuteCode = function(Address:Pointer;R0,R1,R2,R3,R4,R5:LongWord):LongWord;
 TDispmanxHandleGet = function(Resource:THandle):THandle;
 TEDIDBlockGet = function(Block:LongWord;Buffer:Pointer;Length:LongWord):LongWord;

type
 {Prototypes for Framebuffer Handlers}
 TFramebufferAvailable = function:Boolean;
 
 TFramebufferAllocate = function(Alignment:LongWord;var Address,Length:LongWord):LongWord;
 TFramebufferRelease = function:LongWord;
 TFramebufferSetState = function(State:LongWord):LongWord;

 TFramebufferGetDimensions = function(var Width,Height,Top,Bottom,Left,Right:LongWord):LongWord;
 
 TFramebufferGetPhysical = function(var Width,Height:LongWord):LongWord;
 TFramebufferSetPhysical = function(var Width,Height:LongWord):LongWord;
 TFramebufferTestPhysical = function(var Width,Height:LongWord):LongWord;

 TFramebufferGetVirtual = function(var Width,Height:LongWord):LongWord;
 TFramebufferSetVirtual = function(var Width,Height:LongWord):LongWord;
 TFramebufferTestVirtual = function(var Width,Height:LongWord):LongWord;

 TFramebufferGetDepth = function(var Depth:LongWord):LongWord;
 TFramebufferSetDepth = function(var Depth:LongWord):LongWord;
 TFramebufferTestDepth = function(var Depth:LongWord):LongWord;

 TFramebufferGetPixelOrder = function(var Order:LongWord):LongWord;
 TFramebufferSetPixelOrder = function(var Order:LongWord):LongWord;
 TFramebufferTestPixelOrder = function(var Order:LongWord):LongWord;

 TFramebufferGetAlphaMode = function(var Mode:LongWord):LongWord;
 TFramebufferSetAlphaMode = function(var Mode:LongWord):LongWord;
 TFramebufferTestAlphaMode = function(var Mode:LongWord):LongWord;

 TFramebufferGetPitch = function:LongWord;

 TFramebufferGetOffset = function(var X,Y:LongWord):LongWord;
 TFramebufferSetOffset = function(var X,Y:LongWord):LongWord;
 TFramebufferTestOffset = function(var X,Y:LongWord):LongWord;

 TFramebufferGetOverscan = function(var Top,Bottom,Left,Right:LongWord):LongWord;
 TFramebufferSetOverscan = function(var Top,Bottom,Left,Right:LongWord):LongWord;
 TFramebufferTestOverscan = function(var Top,Bottom,Left,Right:LongWord):LongWord;

 TFramebufferGetPalette = function(Buffer:Pointer;Length:LongWord):LongWord;
 TFramebufferSetPalette = function(Start,Count:LongWord;Buffer:Pointer;Length:LongWord):LongWord;
 TFramebufferTestPalette = function(Start,Count:LongWord;Buffer:Pointer;Length:LongWord):LongWord;
 
type
 {Prototypes for Cursor Handlers}
 TCursorSetInfo = function(Width,Height,HotspotX,HotspotY:LongWord;Pixels:Pointer;Length:LongWord):LongWord;
 TCursorSetState = function(Enabled:Boolean;X,Y:LongWord;Relative:Boolean):LongWord;
 
type
 {Prototypes for DMA Handlers}
 TDMAAvailable = function:Boolean;
 
 TDMAGetChannels = function:LongWord;
 
 //To Do //More //Basic DMA Allocate/Submit/Release etc (FillMemory/CopyMemory/ReadMemory/WriteMemory etc)
 
type
 {Prototypes for GPIO Handlers}
 TGPIORead = function(Reg:LongWord):LongWord;
 TGPIOWrite = procedure(Reg,Value:LongWord);
 
 TGPIOInputGet = function(Pin:LongWord):LongWord;
 TGPIOInputWait = function(Pin,Timeout:LongWord):LongWord;
 TGPIOInputEvent = function(Pin,Timeout:LongWord;Callback:TGPIOEvent;Data:Pointer):LongWord;
 
 TGPIOPullSelect = function(Pin,Mode:LongWord):LongWord;
 
 TGPIOOutputSet = procedure(Reg,Value:LongWord);      //To Do //Change from Reg,Value to Pin //Change to function
 TGPIOOutputClear = procedure(Reg,Value:LongWord);    //To Do //Change from Reg,Value to Pin //Change to function
 TGPIOFunctionSelect = procedure(Reg,Value:LongWord); //To Do //Change from Reg,Value to Pin,Mode //Change to function
 
//type
 {Prototypes for PWM Handlers}
 //To Do
 
type
 {Prototypes for RTC Handlers}
 TRTCAvailable = function:Boolean;
 
 TRTCGetTime = function:Int64;
 TRTCSetTime = function(const Time:Int64):LongWord;
 
type
 {Prototypes for Peripheral Handlers}
 TPeripheralGetBase = function:PtrUInt;
 TPeripheralGetSize = function:LongWord;
 TPeripheralRead = function(Base,Reg:LongWord):LongWord;
 TPeripheralWrite = procedure(Base,Reg,Value:LongWord); 

 TLocalPeripheralGetBase = function:PtrUInt;
 TLocalPeripheralGetSize = function:LongWord;
 
type
 {Prototypes for GetSP/PC Handlers}
 TGetSP = function:PtrUInt; 
 TGetPC = function:PtrUInt; 
 
type
 {Prototypes for Enable/Disable/Save/RestoreIRQ/FIQ Handlers}
 TGetIRQ = function:Boolean;
 TEnableIRQ = procedure;
 TDisableIRQ = procedure;
 TSaveIRQ = function:TIRQMask;
 TRestoreIRQ = function(IRQMask:TIRQMask):TIRQMask;

 TGetFIQ = function:Boolean;
 TEnableFIQ = procedure;
 TDisableFIQ = procedure;
 TSaveFIQ = function:TFIQMask;
 TRestoreFIQ = function(FIQMask:TFIQMask):TFIQMask;
 
 TEnableIRQFIQ = procedure;
 TDisableIRQFIQ = procedure;
 TSaveIRQFIQ = function:TIRQFIQMask;
 TRestoreIRQFIQ = function(IRQFIQMask:TIRQFIQMask):TIRQFIQMask;

 TGetAbort = function:Boolean;
 TEnableAbort = procedure;
 TDisableAbort = procedure;
 TSaveAbort = function:TAbortMask;
 TRestoreAbort = function(AbortMask:TAbortMask):TAbortMask;
 
type
 {Prototypes for Halt/Pause Handlers}
 THalt = procedure;
 TPause = procedure;
 
type
 {Prototype for HaltThread Handler}
 THaltThread = function(ExitCode:LongWord):LongWord;
 
type
 {Prototypes for SendEvent/WaitForEvent/Interrupt Handlers}
 TSendEvent = procedure;
 TWaitForEvent = procedure;
 TWaitForInterrupt = procedure;

type
 {Prototypes for Barrier Handlers}
 TReadMemoryBarrier = procedure;
 TWriteMemoryBarrier = procedure;
 
 TDataMemoryBarrier = procedure;
 TDataSynchronizationBarrier = procedure;
 TInstructionMemoryBarrier = procedure;

type
 {Prototypes for TLB Handlers}
 TInvalidateTLB = procedure;
 TInvalidateDataTLB = procedure;
 TInvalidateInstructionTLB = procedure;
 
type
 {Prototypes for Cache Handlers}
 TInvalidateCache = procedure;
 TCleanDataCache = procedure;
 TInvalidateDataCache = procedure;
 TCleanAndInvalidateDataCache = procedure;
 TInvalidateInstructionCache = procedure;
 
 TCleanDataCacheRange = procedure(Address,Size:LongWord);
 TInvalidateDataCacheRange = procedure(Address,Size:LongWord);
 TCleanAndInvalidateDataCacheRange = procedure(Address,Size:LongWord);
 TInvalidateInstructionCacheRange = procedure(Address,Size:LongWord);
 
type
 {Prototypes for Prefetch Buffer Handlers} 
 TFlushPrefetchBuffer = procedure;

type
 {Prototypes for Branch Target Cache Handlers} 
 TFlushBranchTargetCache = procedure;
 
type
 {Prototype for ContextSwitch Handlers}
 TContextSwitch = procedure(OldStack,NewStack:Pointer;NewThread:TThreadHandle);
 TContextSwitchIRQ = procedure(OldStack,NewStack:Pointer;NewThread:TThreadHandle);
 TContextSwitchFIQ = procedure(OldStack,NewStack:Pointer;NewThread:TThreadHandle);
 TContextSwitchSWI = procedure(OldStack,NewStack:Pointer;NewThread:TThreadHandle);
 
type
 {Prototypes for And/Xor/Or/Increment/Decrement/Exchange Handlers}
 TInterlockedOr = function(var Target:LongInt;Value:LongInt):LongInt;
 TInterlockedXor = function(var Target:LongInt;Value:LongInt):LongInt;
 TInterlockedAnd = function(var Target:LongInt;Value:LongInt):LongInt;
 
 TInterlockedDecrement = function(var Target:LongInt):LongInt;
 TInterlockedIncrement = function(var Target:LongInt):LongInt;
 TInterlockedExchange = function(var Target:LongInt;Source:LongInt):LongInt;
 TInterlockedAddExchange = function(var Target:LongInt;Source:LongInt):LongInt;
 TInterlockedCompareExchange = function(var Target:LongInt;Source,Compare:LongInt):LongInt;
 
type
 {Prototypes for PageTable Handlers}
 TPageTableGetBase = function:PtrUInt;
 TPageTableGetSize = function:LongWord;
 TPageTableGetEntry = function(Address:PtrUInt):TPageTableEntry;
 TPageTableSetEntry = function(Address:PtrUInt;const PageTableEntry:TPageTableEntry):LongWord;

 type
 {Prototypes for PageTables Handlers}
 TPageTablesGetAddress = function:PtrUInt;
 TPageTablesGetLength = function:LongWord;
 TPageTablesGetCount = function:LongWord;
 TPageTablesGetShift = function:LongWord;
 
type
 {Prototypes for VectorTable Handlers} 
 TVectorTableGetBase = function:PtrUInt;
 TVectorTableGetSize = function:LongWord;
 TVectorTableGetEntry = function(Number:LongWord):PtrUInt;
 TVectorTableSetEntry = function(Number:LongWord;Address:PtrUInt):LongWord;
 
type
 {Prototype for FirstBitSet Handler} 
 TFirstBitSet = function(Value:LongWord):LongWord; 
 
type
 {Prototype for CountLeadingZeros Handler} 
 TCountLeadingZeros = function(Value:LongWord):LongWord;

type
 {Prototypes for Text IO Handlers} 
 TTextIOWriteChar = function(ACh:Char;AUserData:Pointer):Boolean;
 TTextIOReadChar = function(var ACh:Char;AUserData:Pointer):Boolean;
 
type
 {Prototypes for Console Handlers} 
 TConsoleWriteChar = function(ACh:Char;AUserData:Pointer):Boolean;
 TConsoleReadChar = function(var ACh:Char;AUserData:Pointer):Boolean;
 
 TConsoleHideMouse = function(AUserData:Pointer):Boolean;
 TConsoleShowMouse = function(X,Y:LongWord;AUserData:Pointer):Boolean;
 TConsoleReadMouse = function(var X,Y,Buttons:LongWord;AUserData:Pointer):Boolean;
 
type
 {Prototypes for Name Handlers}
 THostGetName = function:String;
 THostSetName = function(const AName:String):Boolean;
 THostGetDomain = function:String;
 THostSetDomain = function(const ADomain:String):Boolean;
 
type
 {Prototype for Logging Handlers}
 TLoggingOutput = procedure(const AText:String);
 TLoggingOutputEx = procedure(AFacility,ASeverity:LongWord;const ATag,AContent:String);
 
type
 {Text IO Data}
 PTextIOData = ^TTextIOData;
 TTextIOData = record
  WriteChar:TTextIOWriteChar;
  ReadChar:TTextIOReadChar;
  UserData:Pointer;
 end;
 
{==============================================================================}
type
 {Platform specific classes}
 EHardwareException = class(Exception)
  protected
   {Protected Variables}
   AllowFree:Boolean;
  public
   {Public Methods}
   procedure FreeInstance; override;
 end;
 
 EDataAbort = class(EHardwareException);
 EPrefetchAbort = class(EHardwareException);
 EUndefinedInstruction = class(EHardwareException);
 
{==============================================================================}
var
 {Platform specific variables}
 PlatformInitialized:Boolean;
 
 CPUInitialized:Boolean;
 FPUInitialized:Boolean;
 GPUInitialized:Boolean;
 MMUInitialized:Boolean;
 SMPInitialized:Boolean;
 CacheInitialized:Boolean;
 BoardInitialized:Boolean;
 MemoryInitialized:Boolean;
 ClockInitialized:Boolean;
 PowerInitialized:Boolean;
 MailboxInitialized:Boolean;
 InterruptsInitialized:Boolean;
 PeripheralsInitialized:Boolean;
 
 ParseBootTagsCompleted:Boolean;
 ParseCommandLineCompleted:Boolean;
 ParseEnvironmentCompleted:Boolean;
 
var
 {Lock Variables}
 ClockLock:TPlatformLock;
 PowerLock:TPlatformLock;
 MailboxLock:TPlatformLock;
 ShutdownLock:TPlatformLock;
 InterruptLock:TPlatformLock;
 
var
 {Semaphore Variables}
 ShutdownSemaphore:TPlatformSemaphore;
 
var
 {Clock Variables}
 ClockBase:Int64 = TIME_TICKS_TO_1899;  {The system time as of the last setting of the clock}
 ClockLast:LongWord;                    {The timer value of the last clock tick}
 ClockTicks:LongWord;                   {Current number of clock ticks (When this reaches CLOCK_TICKS_PER_SECOND then ClockSeconds is incremented and this is reset to zero)}
 ClockSeconds:LongWord;                 {Current number of clock seconds (This forms the system clock)}
 
 {$IFDEF CLOCK_DEBUG}
 ClockInterruptCounter:Int64;
 ClockInterruptOffset:LongWord;
 ClockInterruptMinOffset:LongWord;
 ClockInterruptMaxOffset:LongWord;
 ClockInterruptRollover:LongWord;
 {$ENDIF}

 {$IFDEF INTERRUPT_DEBUG}
 DispatchInterruptCounter:array of Int64; 
 DispatchFastInterruptCounter:array of Int64; 
 DispatchSoftwareInterruptCounter:array of Int64; 
 {$ENDIF}
 
 {$IFDEF EXCEPTION_DEBUG}
 HardwareExceptionCounter:Int64;
 UnhandledExceptionCounter:Int64;
 
 HardwareExceptionAddress:LongWord;
 {$ENDIF}
 
var
 {Utilization Variables}
 UtilizationLast:array of LongWord;     {The per CPU utilization for the last second (Allocated by scheduler initialization)} 
 UtilizationCurrent:array of LongWord;  {The per CPU utilization for the current second (Updated by Idle thread and reset by Scheduler interrupt) (Allocated by scheduler initialization)}
 
var
 {Initialization Handlers}
 CPUInitHandler:TCPUInit;
 FPUInitHandler:TFPUInit;
 GPUInitHandler:TGPUInit;
 MMUInitHandler:TMMUInit;
 SMPInitHandler:TSMPInit;
 CacheInitHandler:TCacheInit;
 BoardInitHandler:TBoardInit;
 MemoryInitHandler:TMemoryInit;
 ClockInitHandler:TClockInit;
 PowerInitHandler:TPowerInit;
 MailboxInitHandler:TMailboxInit;
 InterruptInitHandler:TInterruptInit;
 PeripheralInitHandler:TPeripheralInit;
 
 ParseBootTagsHandler:TParseBootTags;
 ParseCommandLineHandler:TParseCommandLine;
 ParseEnvironmentHandler:TParseEnvironment;

var
 {Blink Handlers}
 BootBlinkHandler:TBootBlink;
 
var
 {LED Handlers}
 PowerLEDEnableHandler:TPowerLEDEnable;
 PowerLEDOnHandler:TPowerLEDOn;
 PowerLEDOffHandler:TPowerLEDOff;
 
 ActivityLEDEnableHandler:TActivityLEDEnable;
 ActivityLEDOnHandler:TActivityLEDOn;
 ActivityLEDOffHandler:TActivityLEDOff;

var
 {Mailbox Handlers}
 MailboxReceiveHandler:TMailboxReceive; 
 MailboxSendHandler:TMailboxSend;
 
 MailboxCallHandler:TMailboxCall;
 MailboxCallExHandler:TMailboxCallEx;
 MailboxPropertyCallHandler:TMailboxPropertyCall;
 MailboxPropertyCallExHandler:TMailboxPropertyCallEx;
 
var
 {Random Handlers}
 RandomAvailableHandler:TRandomAvailable;
 
 RandomSeedHandler:TRandomSeed;

 RandomReadLongIntHandler:TRandomReadLongInt;
 RandomReadInt64Handler:TRandomReadInt64;
 RandomReadExtendedHandler:TRandomReadExtended;
 
var
 {Watchdog Handlers}
 WatchdogAvailableHandler:TWatchdogAvailable;
 
 WatchdogStartHandler:TWatchdogStart;
 WatchdogStopHandler:TWatchdogStop;
 WatchdogRefreshHandler:TWatchdogRefresh;
 
var
 {Interrupt Request (IRQ) Handlers}
 RequestIRQHandler:TRequestIRQ;
 ReleaseIRQHandler:TReleaseIRQ;
 RequestExIRQHandler:TRequestExIRQ;
 ReleaseExIRQHandler:TReleaseExIRQ;

var
 {Fast Interrupt Request (FIQ) Handlers}
 RequestFIQHandler:TRequestFIQ;
 ReleaseFIQHandler:TReleaseFIQ;
 RequestExFIQHandler:TRequestExFIQ;
 ReleaseExFIQHandler:TReleaseExFIQ;
 
var
 {System Handlers} 
 SystemRestartHandler:TSystemRestart;
 SystemShutdownHandler:TSystemShutdown;
 SystemGetUptimeHandler:TSystemGetUptime;
 SystemGetCommandLineHandler:TSystemGetCommandLine;
 SystemGetEnvironmentHandler:TSystemGetEnvironment;
 SystemCallHandler:TSystemCall;
 
var
 {CPU Handlers}
 CPUGetTypeHandler:TCPUGetType;
 CPUGetBootHandler:TCPUGetBoot;
 CPUGetMaskHandler:TCPUGetMask;
 CPUGetCountHandler:TCPUGetCount;
 CPUGetModeHandler:TCPUGetMode;
 CPUGetStateHandler:TCPUGetState;
 CPUGetCurrentHandler:TCPUGetCurrent;
 CPUGetMemoryHandler:TCPUGetMemory;
 CPUGetPercentageHandler:TCPUGetPercentage;
 CPUGetUtilizationHandler:TCPUGetUtilization;

 CPUGetModelHandler:TCPUGetModel;
 CPUGetRevisionHandler:TCPUGetRevision;
 CPUGetDescriptionHandler:TCPUGetDescription;
 
var
 {FPU Handlers}
 FPUGetTypeHandler:TFPUGetType;
 FPUGetStateHandler:TFPUGetState;
 
var
 {GPU Handlers}
 GPUGetTypeHandler:TGPUGetType;
 GPUGetStateHandler:TGPUGetState;
 GPUGetMemoryHandler:TGPUGetMemory;
 
var
 {Cache Handlers}
 L1CacheGetTypeHandler:TL1CacheGetType;
 L1DataCacheGetSizeHandler:TL1DataCacheGetSize;
 L1DataCacheGetLineSizeHandler:TL1DataCacheGetLineSize;
 L1InstructionCacheGetSizeHandler:TL1InstructionCacheGetSize;
 L1InstructionCacheGetLineSizeHandler:TL1InstructionCacheGetLineSize;
 
 L2CacheGetTypeHandler:TL2CacheGetType;
 L2CacheGetSizeHandler:TL2CacheGetSize;
 L2CacheGetLineSizeHandler:TL2CacheGetLineSize;
 
var
 {Board Handlers}
 BoardGetTypeHandler:TBoardGetType;
 BoardGetModelHandler:TBoardGetModel;
 BoardGetSerialHandler:TBoardGetSerial;
 BoardGetRevisionHandler:TBoardGetRevision;
 BoardGetMACAddressHandler:TBoardGetMACAddress;
 
var
 {Firmware Handlers}
 FirmwareGetRevisionHandler:TFirmwareGetRevision;
 
var
 {Machine Handlers}
 MachineGetTypeHandler:TMachineGetType;

var
 {Memory Handlers}
 MemoryGetBaseHandler:TMemoryGetBase;
 MemoryGetSizeHandler:TMemoryGetSize;
 
 MemoryGetPageSizeHandler:TMemoryGetPageSize;
 MemoryGetLargePageSizeHandler:TMemoryGetLargePageSize;

var
 {Power Handlers}
 PowerGetWaitHandler:TPowerGetWait;
 PowerGetStateHandler:TPowerGetState;
 PowerSetStateHandler:TPowerSetState;

var
 {Clock Handlers}
 ClockGetCountHandler:TClockGetCount;
 ClockGetTotalHandler:TClockGetTotal;
 
 ClockUpdateOffsetHandler:TClockUpdateOffset;
 
 ClockGetRateHandler:TClockGetRate;
 ClockSetRateHandler:TClockSetRate;
 ClockGetStateHandler:TClockGetState;
 ClockSetStateHandler:TClockSetState;
 ClockGetMinRateHandler:TClockGetMinRate;
 ClockGetMaxRateHandler:TClockGetMaxRate;

var
 {Turbo Handlers}
 TurboGetStateHandler:TTurboGetState;
 TurboSetStateHandler:TTurboSetState;

var
 {Voltage Handlers}
 VoltageGetValueHandler:TVoltageGetValue;
 VoltageSetValueHandler:TVoltageSetValue;

 VoltageGetMinValueHandler:TVoltageGetMinValue;
 VoltageGetMaxValueHandler:TVoltageGetMaxValue;
 
var
 {Temperature Handlers}
 TemperatureGetCurrentHandler:TTemperatureGetCurrent;
 TemperatureGetMaximumHandler:TTemperatureGetMaximum;

var
 {GPU Memory Handlers}
 GPUMemoryAllocateHandler:TGPUMemoryAllocate;
 GPUMemoryReleaseHandler:TGPUMemoryRelease;
 GPUMemoryLockHandler:TGPUMemoryLock;
 GPUMemoryUnlockHandler:TGPUMemoryUnlock;

 var
 {GPU Misc Handlers}
 GPUExecuteCodeHandler:TGPUExecuteCode;
 DispmanxHandleGetHandler:TDispmanxHandleGet;
 EDIDBlockGetHandler:TEDIDBlockGet;
 
var
 {Framebuffer Handlers}
 FramebufferAvailableHandler:TFramebufferAvailable;
 
 FramebufferAllocateHandler:TFramebufferAllocate;
 FramebufferReleaseHandler:TFramebufferRelease;
 FramebufferSetStateHandler:TFramebufferSetState;

 FramebufferGetDimensionsHandler:TFramebufferGetDimensions;
 
 FramebufferGetPhysicalHandler:TFramebufferGetPhysical;
 FramebufferSetPhysicalHandler:TFramebufferSetPhysical;
 FramebufferTestPhysicalHandler:TFramebufferTestPhysical;

 FramebufferGetVirtualHandler:TFramebufferGetVirtual;
 FramebufferSetVirtualHandler:TFramebufferSetVirtual;
 FramebufferTestVirtualHandler:TFramebufferTestVirtual;

 FramebufferGetDepthHandler:TFramebufferGetDepth;
 FramebufferSetDepthHandler:TFramebufferSetDepth;
 FramebufferTestDepthHandler:TFramebufferTestDepth;

 FramebufferGetPixelOrderHandler:TFramebufferGetPixelOrder;
 FramebufferSetPixelOrderHandler:TFramebufferSetPixelOrder;
 FramebufferTestPixelOrderHandler:TFramebufferTestPixelOrder;

 FramebufferGetAlphaModeHandler:TFramebufferGetAlphaMode;
 FramebufferSetAlphaModeHandler:TFramebufferSetAlphaMode;
 FramebufferTestAlphaModeHandler:TFramebufferTestAlphaMode;

 FramebufferGetPitchHandler:TFramebufferGetPitch;

 FramebufferGetOffsetHandler:TFramebufferGetOffset;
 FramebufferSetOffsetHandler:TFramebufferSetOffset;
 FramebufferTestOffsetHandler:TFramebufferTestOffset;

 FramebufferGetOverscanHandler:TFramebufferGetOverscan;
 FramebufferSetOverscanHandler:TFramebufferSetOverscan;
 FramebufferTestOverscanHandler:TFramebufferTestOverscan;

 FramebufferGetPaletteHandler:TFramebufferGetPalette;
 FramebufferSetPaletteHandler:TFramebufferSetPalette;
 FramebufferTestPaletteHandler:TFramebufferTestPalette;
 
var
 {Cursor Handlers}
 CursorSetInfoHandler:TCursorSetInfo;
 CursorSetStateHandler:TCursorSetState;
 
var
 {DMA Handlers}
 DMAAvailableHandler:TDMAAvailable;
 DMAGetChannelsHandler:TDMAGetChannels;
 
 //To Do //More //Basic DMA Allocate/Submit/Release etc (FillMemory/CopyMemory/ReadMemory/WriteMemory etc)
 
var
 {GPIO Handlers} 
 GPIOReadHandler:TGPIORead;
 GPIOWriteHandler:TGPIOWrite;
 
 GPIOInputGetHandler:TGPIOInputGet;
 GPIOInputWaitHandler:TGPIOInputWait;
 GPIOInputEventHandler:TGPIOInputEvent;
 
 GPIOPullSelectHandler:TGPIOPullSelect;
 
 GPIOOutputSetHandler:TGPIOOutputSet;
 GPIOOutputClearHandler:TGPIOOutputClear;
 GPIOFunctionSelectHandler:TGPIOFunctionSelect;
 
//var
 {PWM Handlers}
 //To Do
 
var
 {RTC Handlers} 
 RTCAvailableHandler:TRTCAvailable;
 RTCGetTimeHandler:TRTCGetTime;
 RTCSetTimeHandler:TRTCSetTime;
 
var
 {Peripheral Handlers}
 PeripheralGetBaseHandler:TPeripheralGetBase;
 PeripheralGetSizeHandler:TPeripheralGetSize;
 PeripheralReadHandler:TPeripheralRead;
 PeripheralWriteHandler:TPeripheralWrite;
 
 LocalPeripheralGetBaseHandler:TLocalPeripheralGetBase;
 LocalPeripheralGetSizeHandler:TLocalPeripheralGetSize;
 
var
 {GetSP/PC Handlers}
 GetSPHandler:TGetSP;
 GetPCHandler:TGetPC;
 
var
 {Enable/Disable/Save/RestoreIRQ/FIQ Handlers} 
 GetIRQHandler:TGetIRQ;
 EnableIRQHandler:TEnableIRQ;
 DisableIRQHandler:TDisableIRQ;
 SaveIRQHandler:TSaveIRQ;
 RestoreIRQHandler:TRestoreIRQ;

 GetFIQHandler:TGetFIQ;
 EnableFIQHandler:TEnableFIQ;
 DisableFIQHandler:TDisableFIQ;
 SaveFIQHandler:TSaveFIQ;
 RestoreFIQHandler:TRestoreFIQ;
 
 EnableIRQFIQHandler:TEnableIRQFIQ;
 DisableIRQFIQHandler:TDisableIRQFIQ;
 SaveIRQFIQHandler:TSaveIRQFIQ;
 RestoreIRQFIQHandler:TRestoreIRQFIQ;

 GetAbortHandler:TGetAbort;
 EnableAbortHandler:TEnableAbort;
 DisableAbortHandler:TDisableAbort;
 SaveAbortHandler:TSaveAbort;
 RestoreAbortHandler:TRestoreAbort;
 
var 
 {Halt/Pause Handlers}
 HaltHandler:THalt;
 PauseHandler:TPause;

var
 {HaltThread Handler}
 HaltThreadHandler:THaltThread;
 
var
 {SendEvent/WaitForEvent/Interrupt Handlers}
 SendEventHandler:TSendEvent;
 WaitForEventHandler:TWaitForEvent;
 WaitForInterruptHandler:TWaitForInterrupt;

var
 {Barrier Handlers}
 ReadMemoryBarrierHandler:TReadMemoryBarrier;
 WriteMemoryBarrierHandler:TWriteMemoryBarrier;

 DataMemoryBarrierHandler:TDataMemoryBarrier;
 DataSynchronizationBarrierHandler:TDataSynchronizationBarrier;
 InstructionMemoryBarrierHandler:TInstructionMemoryBarrier;
 
var
 {TLB Handlers}
 InvalidateTLBHandler:TInvalidateTLB;
 InvalidateDataTLBHandler:TInvalidateDataTLB;
 InvalidateInstructionTLBHandler:TInvalidateInstructionTLB;
 
var
 {Cache Handlers}
 InvalidateCacheHandler:TInvalidateCache;
 CleanDataCacheHandler:TCleanDataCache;
 InvalidateDataCacheHandler:TInvalidateDataCache;
 CleanAndInvalidateDataCacheHandler:TCleanAndInvalidateDataCache;
 InvalidateInstructionCacheHandler:TInvalidateInstructionCache;
 
 CleanDataCacheRangeHandler:TCleanDataCacheRange;
 InvalidateDataCacheRangeHandler:TInvalidateDataCacheRange;
 CleanAndInvalidateDataCacheRangeHandler:TCleanAndInvalidateDataCacheRange;
 InvalidateInstructionCacheRangeHandler:TInvalidateInstructionCacheRange;
 
var
 {Prefetch Buffer Handlers}
 FlushPrefetchBufferHandler:TFlushPrefetchBuffer;
 
var
 {Branch Target Cache Handlers}
 FlushBranchTargetCacheHandler:TFlushBranchTargetCache;
 
var
 {ContextSwitch Handlers}
 ContextSwitchHandler:TContextSwitch;
 ContextSwitchIRQHandler:TContextSwitchIRQ;
 ContextSwitchFIQHandler:TContextSwitchFIQ;
 ContextSwitchSWIHandler:TContextSwitchSWI;

var
 {And/Xor/Or/Increment/Decrement/Exchange Handlers}
 InterlockedOrHandler:TInterlockedOr;
 InterlockedXorHandler:TInterlockedXor;
 InterlockedAndHandler:TInterlockedAnd;
 
 InterlockedDecrementHandler:TInterlockedDecrement;
 InterlockedIncrementHandler:TInterlockedIncrement;
 InterlockedExchangeHandler:TInterlockedExchange;
 InterlockedAddExchangeHandler:TInterlockedAddExchange;
 InterlockedCompareExchangeHandler:TInterlockedCompareExchange;
 
var
 {PageTable Handlers}
 PageTableGetBaseHandler:TPageTableGetBase;
 PageTableGetSizeHandler:TPageTableGetSize;
 PageTableGetEntryHandler:TPageTableGetEntry; 
 PageTableSetEntryHandler:TPageTableSetEntry;
 
var
 {PageTables Handlers}
 PageTablesGetAddressHandler:TPageTablesGetAddress;
 PageTablesGetLengthHandler:TPageTablesGetLength;
 PageTablesGetCountHandler:TPageTablesGetCount;
 PageTablesGetShiftHandler:TPageTablesGetShift;
 
var
 {VectorTable Handlers} 
 VectorTableGetBaseHandler:TVectorTableGetBase;
 VectorTableGetSizeHandler:TVectorTableGetSize;
 VectorTableGetEntryHandler:TVectorTableGetEntry;
 VectorTableSetEntryHandler:TVectorTableSetEntry;
 
var
 {FirstBitSet Handler} 
 FirstBitSetHandler:TFirstBitSet;
 
var
 {CountLeadingZeros Handlers}
 CountLeadingZerosHandler:TCountLeadingZeros;

var
 {Console Handlers}
 ConsoleWriteCharHandler:TConsoleWriteChar;
 ConsoleReadCharHandler:TConsoleReadChar;
 
 ConsoleHideMouseHandler:TConsoleHideMouse;
 ConsoleShowMouseHandler:TConsoleShowMouse;
 ConsoleReadMouseHandler:TConsoleReadMouse;
 
var
 {Name Handlers}
 HostGetNameHandler:THostGetName;
 HostSetNameHandler:THostSetName;
 HostGetDomainHandler:THostGetDomain;
 HostSetDomainHandler:THostSetDomain;
 
var 
 {Logging Handlers}
 LoggingOutputHandler:TLoggingOutput;
 LoggingOutputExHandler:TLoggingOutputEx;

{==============================================================================}
{Initialization Functions}
procedure PlatformInit;
 
procedure CPUInit;
procedure FPUInit;
procedure GPUInit;
procedure MMUInit;
procedure SMPInit;

procedure CacheInit;
procedure BoardInit;
procedure MemoryInit;
procedure ClockInit;
procedure PowerInit;
procedure MailboxInit;
procedure InterruptInit;
procedure PeripheralInit;

procedure ParseBootTags;
procedure ParseCommandLine;
procedure ParseEnvironment;

{==============================================================================}
{Boot Functions}
procedure BootBlink; inline;

{==============================================================================}
{LED Functions}
procedure PowerLEDEnable; inline;
procedure PowerLEDOn; inline;
procedure PowerLEDOff; inline;

procedure ActivityLEDEnable; inline;
procedure ActivityLEDOn; inline;
procedure ActivityLEDOff; inline;

{==============================================================================}
{Timer Functions}
//To Do //See Timer device

{==============================================================================}
{Mailbox Functions}
function MailboxReceive(Mailbox,Channel:LongWord):LongWord; inline;
procedure MailboxSend(Mailbox,Channel,Data:LongWord); inline;

function MailboxCall(Mailbox,Channel,Data:LongWord;var Response:LongWord):LongWord; inline;
function MailboxCallEx(Mailbox,Channel,Data:LongWord;var Response:LongWord;Timeout:LongWord):LongWord; inline;
function MailboxPropertyCall(Mailbox,Channel:LongWord;Data:Pointer;var Response:LongWord):LongWord; inline;
function MailboxPropertyCallEx(Mailbox,Channel:LongWord;Data:Pointer;var Response:LongWord;Timeout:LongWord):LongWord; inline;

{==============================================================================}
{Random Number Functions}
function RandomAvailable:Boolean; inline;

procedure RandomSeed(Seed:LongWord); inline;

function RandomReadLongInt(Limit:LongInt):LongInt; inline;
function RandomReadInt64(Limit:Int64):Int64; inline;
function RandomReadExtended:Extended; inline;

{==============================================================================}
{Watchdog Functions}
function WatchdogAvailable:Boolean; inline; 

function WatchdogStart(Milliseconds:LongWord):LongWord; inline; 
function WatchdogStop:LongWord; inline;
function WatchdogRefresh(Milliseconds:LongWord):LongWord; inline;

{==============================================================================}
{Interrupt Request (IRQ) Functions}
function RequestIRQ(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord; inline;
function ReleaseIRQ(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord; inline;
function RequestExIRQ(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord; inline;
function ReleaseExIRQ(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord; inline;

{==============================================================================}
{Fast Interrupt Request (FIQ) Functions}
function RequestFIQ(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord; inline;
function ReleaseFIQ(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord; inline;
function RequestExFIQ(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord; inline;
function ReleaseExFIQ(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord; inline;

{==============================================================================}
{System Functions}
function SystemRestart(Delay:LongWord):LongWord; inline;
function SystemShutdown(Delay:LongWord):LongWord; inline;
//function SystemRegister //To Do //Register Shutdown/Restart handler
//function SystemDeregister //To Do //Deregister Shutdown/Restart handler
function SystemGetUptime:Int64; inline;
function SystemGetCommandLine:String; inline;
function SystemGetEnvironment:Pointer; inline;

procedure SystemCall(Number:LongWord;Param1,Param2,Param3:PtrUInt); inline;

{==============================================================================}
{CPU Functions}
function CPUGetType:LongWord; inline;
function CPUGetBoot:LongWord; inline;
function CPUGetMask:LongWord; inline;
function CPUGetCount:LongWord; inline;
function CPUGetMode:LongWord; inline;
function CPUGetState:LongWord; inline;
function CPUGetCurrent:LongWord; inline;
function CPUGetMemory(var Address:PtrUInt;var Length:LongWord):LongWord; inline; 
function CPUGetPercentage(CPUID:LongWord):Double; inline;
function CPUGetUtilization(CPUID:LongWord):LongWord; inline;

function CPUGetModel:LongWord; inline;
function CPUGetRevision:LongWord; inline;
function CPUGetDescription:String; inline;

{==============================================================================}
{FPU Functions}
function FPUGetType:LongWord; inline;
function FPUGetState:LongWord; inline;

{==============================================================================}
{GPU Functions}
function GPUGetType:LongWord; inline;
function GPUGetState:LongWord; inline;
function GPUGetMemory(var Address:PtrUInt;var Length:LongWord):LongWord; inline; 

{==============================================================================}
{Cache Functions}
function L1CacheGetType:LongWord; inline; 
function L1DataCacheGetSize:LongWord; inline; 
function L1DataCacheGetLineSize:LongWord; inline; 
function L1InstructionCacheGetSize:LongWord; inline; 
function L1InstructionCacheGetLineSize:LongWord; inline; 

function L2CacheGetType:LongWord; inline; 
function L2CacheGetSize:LongWord; inline; 
function L2CacheGetLineSize:LongWord; inline; 

{==============================================================================}
{Board Functions}
function BoardGetType:LongWord; inline;
function BoardGetModel:LongWord; inline;
function BoardGetSerial:Int64; inline;
function BoardGetRevision:LongWord; inline;
function BoardGetMACAddress:String; inline;

{==============================================================================}
{Firmware Functions}
function FirmwareGetRevision:LongWord; inline;

{==============================================================================}
{Machine Functions}
function MachineGetType:LongWord; inline;

{==============================================================================}
{Memory Functions}
function MemoryGetBase:PtrUInt; inline;
function MemoryGetSize:LongWord; inline;

function MemoryGetPageSize:LongWord; inline;
function MemoryGetLargePageSize:LongWord; inline;

{==============================================================================}
{Power Functions}
function PowerOn(PowerId:LongWord):LongWord;
function PowerOff(PowerId:LongWord):LongWord;

function PowerGetWait(PowerId:LongWord):LongWord; inline;
function PowerGetState(PowerId:LongWord):LongWord; inline;
function PowerSetState(PowerId,State:LongWord;Wait:Boolean):LongWord; inline;

{==============================================================================}
{Clock Functions}
function ClockGetTime:Int64;
function ClockSetTime(const Time:Int64):LongWord;

function ClockGetCount:LongWord; inline;
function ClockGetTotal:Int64; inline;

function ClockUpdateOffset:LongWord; inline;

function ClockGetRate(ClockId:LongWord):LongWord; inline;
function ClockSetRate(ClockId,Rate:LongWord;Turbo:Boolean):LongWord; inline;

function ClockGetState(ClockId:LongWord):LongWord; inline;
function ClockSetState(ClockId,State:LongWord):LongWord; inline;

function ClockGetMinRate(ClockId:LongWord):LongWord; inline;
function ClockGetMaxRate(ClockId:LongWord):LongWord; inline;

{==============================================================================}
{Turbo Functions}
function TurboGetState(TurboId:LongWord):LongWord; inline;
function TurboSetState(TurboId,State:LongWord):LongWord; inline;

{==============================================================================}
{Voltage Functions}
function VoltageGetValue(VoltageId:LongWord):LongWord; inline;
function VoltageSetValue(VoltageId,Value:LongWord):LongWord; inline;

function VoltageGetMinValue(VoltageId:LongWord):LongWord; inline;
function VoltageGetMaxValue(VoltageId:LongWord):LongWord; inline;
 
{==============================================================================}
{Temperature Functions}
function TemperatureGetCurrent(TemperatureId:LongWord):LongWord; inline;
function TemperatureGetMaximum(TemperatureId:LongWord):LongWord; inline;

{==============================================================================}
{GPU Memory Functions}
function GPUMemoryAllocate(Length,Alignment,Flags:LongWord):THandle; inline;
function GPUMemoryRelease(Handle:THandle):LongWord; inline;
function GPUMemoryLock(Handle:THandle):LongWord; inline;
function GPUMemoryUnlock(Handle:THandle):LongWord; inline;

{==============================================================================}
{GPU Misc Functions}
function GPUExecuteCode(Address:Pointer;R0,R1,R2,R3,R4,R5:LongWord):LongWord; inline;

function DispmanxHandleGet(Resource:THandle):THandle; inline;
function EDIDBlockGet(Block:LongWord;Buffer:Pointer;Length:LongWord):LongWord; inline;

{==============================================================================}
{Framebuffer Functions}
function FramebufferAvailable:Boolean; inline;

function FramebufferAllocate(Alignment:LongWord;var Address,Length:LongWord):LongWord; inline;
function FramebufferRelease:LongWord; inline;
function FramebufferSetState(State:LongWord):LongWord; inline;

function FramebufferGetDimensions(var Width,Height,Top,Bottom,Left,Right:LongWord):LongWord; inline;

function FramebufferGetPhysical(var Width,Height:LongWord):LongWord; inline;
function FramebufferSetPhysical(var Width,Height:LongWord):LongWord; inline;
function FramebufferTestPhysical(var Width,Height:LongWord):LongWord; inline;

function FramebufferGetVirtual(var Width,Height:LongWord):LongWord; inline;
function FramebufferSetVirtual(var Width,Height:LongWord):LongWord; inline;
function FramebufferTestVirtual(var Width,Height:LongWord):LongWord; inline;

function FramebufferGetDepth(var Depth:LongWord):LongWord; inline;
function FramebufferSetDepth(var Depth:LongWord):LongWord; inline;
function FramebufferTestDepth(var Depth:LongWord):LongWord; inline;

function FramebufferGetPixelOrder(var Order:LongWord):LongWord; inline;
function FramebufferSetPixelOrder(var Order:LongWord):LongWord; inline;
function FramebufferTestPixelOrder(var Order:LongWord):LongWord; inline;

function FramebufferGetAlphaMode(var Mode:LongWord):LongWord; inline;
function FramebufferSetAlphaMode(var Mode:LongWord):LongWord; inline;
function FramebufferTestAlphaMode(var Mode:LongWord):LongWord; inline;

function FramebufferGetPitch:LongWord; inline;

function FramebufferGetOffset(var X,Y:LongWord):LongWord; inline;
function FramebufferSetOffset(var X,Y:LongWord):LongWord; inline;
function FramebufferTestOffset(var X,Y:LongWord):LongWord; inline;

function FramebufferGetOverscan(var Top,Bottom,Left,Right:LongWord):LongWord; inline;
function FramebufferSetOverscan(var Top,Bottom,Left,Right:LongWord):LongWord; inline;
function FramebufferTestOverscan(var Top,Bottom,Left,Right:LongWord):LongWord; inline;

function FramebufferGetPalette(Buffer:Pointer;Length:LongWord):LongWord; inline;
function FramebufferSetPalette(Start,Count:LongWord;Buffer:Pointer;Length:LongWord):LongWord; inline;
function FramebufferTestPalette(Start,Count:LongWord;Buffer:Pointer;Length:LongWord):LongWord; inline;

{==============================================================================}
{Cursor Functions}
function CursorSetInfo(Width,Height,HotspotX,HotspotY:LongWord;Pixels:Pointer;Length:LongWord):LongWord; inline;
function CursorSetState(Enabled:Boolean;X,Y:LongWord;Relative:Boolean):LongWord; inline;

{==============================================================================}
{DMA Functions}
function DMAAvailable:Boolean; inline;

function DMAGetChannels:LongWord; inline;

//To Do //More //Basic DMA Allocate/Submit/Release etc (FillMemory/CopyMemory/ReadMemory/WriteMemory etc)

{==============================================================================}
{Handle Functions}
//To Do
//HandleCreate
//HandleDestroy

//HandleGet
//HandleOpen
//HandleClose
//HandleDuplicate

//etc

{==============================================================================}
{GPIO Functions}
function GPIORead(Reg:LongWord):LongWord; inline;
procedure GPIOWrite(Reg,Value:LongWord); inline;

function GPIOInputGet(Pin:LongWord):LongWord; inline;
function GPIOInputWait(Pin,Timeout:LongWord):LongWord; inline;
function GPIOInputEvent(Pin,Timeout:LongWord;Callback:TGPIOEvent;Data:Pointer):LongWord; inline;
 
function GPIOPullSelect(Pin,Mode:LongWord):LongWord; inline;

procedure GPIOOutputSet(Reg,Value:LongWord); inline;       //To Do //Change from Reg,Value to Pin //Change to function
procedure GPIOOutputClear(Reg,Value:LongWord); inline;     //To Do //Change from Reg,Value to Pin //Change to function
procedure GPIOFunctionSelect(Reg,Value:LongWord); inline;  //To Do //Change from Reg,Value to Pin,Mode //Change to function

{==============================================================================}
{PWM Functions}
//To Do

{==============================================================================}
{RTC Functions}
function RTCAvailable:Boolean; inline;

function RTCGetTime:Int64; inline;
function RTCSetTime(const Time:Int64):LongWord; inline;

{==============================================================================}
{Peripheral Functions}
function PeripheralGetBase:PtrUInt; inline;
function PeripheralGetSize:LongWord; inline;

function PeripheralRead(Base,Reg:LongWord):LongWord; inline;
procedure PeripheralWrite(Base,Reg,Value:LongWord); inline;

function LocalPeripheralGetBase:PtrUInt; inline;
function LocalPeripheralGetSize:LongWord; inline;

{==============================================================================}
{System Functions}
function GetSP:PtrUInt; inline;
function GetPC:PtrUInt; inline;

function GetIRQ:Boolean; inline;
procedure EnableIRQ; inline;
procedure DisableIRQ; inline;
function SaveIRQ:TIRQMask; inline;
function RestoreIRQ(IRQMask:TIRQMask):TIRQMask; inline;

function GetFIQ:Boolean; inline;
procedure EnableFIQ; inline;
procedure DisableFIQ; inline;
function SaveFIQ:TFIQMask; inline;
function RestoreFIQ(FIQMask:TFIQMask):TFIQMask; inline;

procedure EnableIRQFIQ; inline;
procedure DisableIRQFIQ; inline;
function SaveIRQFIQ:TIRQFIQMask; inline;
function RestoreIRQFIQ(IRQFIQMask:TIRQFIQMask):TIRQFIQMask; inline;

function GetAbort:Boolean; inline;
procedure EnableAbort; inline;
procedure DisableAbort; inline;
function SaveAbort:TAbortMask; inline;
function RestoreAbort(AbortMask:TAbortMask):TAbortMask; inline;

procedure Halt; inline;
procedure Pause; inline;

function HaltThread(ExitCode:LongWord):LongWord; inline;

procedure SendEvent; inline;
procedure WaitForEvent; inline;
procedure WaitForInterrupt; inline;

procedure ReadMemoryBarrier; inline;
procedure WriteMemoryBarrier; inline;

procedure DataMemoryBarrier; inline;
procedure DataSynchronizationBarrier; inline;
procedure InstructionMemoryBarrier; inline;

procedure InvalidateTLB; inline;
procedure InvalidateDataTLB; inline;
procedure InvalidateInstructionTLB; inline;

procedure InvalidateCache; inline;
procedure CleanDataCache; inline;
procedure InvalidateDataCache; inline;
procedure CleanAndInvalidateDataCache; inline;
procedure InvalidateInstructionCache; inline;

procedure CleanDataCacheRange(Address,Size:LongWord); inline;
procedure InvalidateDataCacheRange(Address,Size:LongWord); inline;
procedure CleanAndInvalidateDataCacheRange(Address,Size:LongWord); inline;
procedure InvalidateInstructionCacheRange(Address,Size:LongWord); inline;

procedure FlushPrefetchBuffer; inline;

procedure FlushBranchTargetCache; inline;

procedure ContextSwitch(OldStack,NewStack:Pointer;NewThread:TThreadHandle); inline;
procedure ContextSwitchIRQ(OldStack,NewStack:Pointer;NewThread:TThreadHandle); inline;
procedure ContextSwitchFIQ(OldStack,NewStack:Pointer;NewThread:TThreadHandle); inline;
procedure ContextSwitchSWI(OldStack,NewStack:Pointer;NewThread:TThreadHandle); inline;

function InterlockedOr(var Target:LongInt;Value:LongInt):LongInt; inline;
function InterlockedXor(var Target:LongInt;Value:LongInt):LongInt; inline;
function InterlockedAnd(var Target:LongInt;Value:LongInt):LongInt; inline;

function InterlockedDecrement(var Target:LongInt):LongInt; inline;
function InterlockedIncrement(var Target:LongInt):LongInt; inline;
function InterlockedExchange(var Target:LongInt;Source:LongInt):LongInt; inline;
function InterlockedAddExchange(var Target:LongInt;Source:LongInt):LongInt; inline;
function InterlockedCompareExchange(var Target:LongInt;Source,Compare:LongInt):LongInt; inline;

function PageTableGetBase:PtrUInt; inline;
function PageTableGetSize:LongWord; inline;
function PageTableGetEntry(Address:PtrUInt):TPageTableEntry; inline;
function PageTableSetEntry(Address:PtrUInt;const PageTableEntry:TPageTableEntry):LongWord; inline;

function PageTablesGetAddress:PtrUInt; inline;
function PageTablesGetLength:LongWord; inline;
function PageTablesGetCount:LongWord; inline;
function PageTablesGetShift:LongWord; inline;

function VectorTableGetBase:PtrUInt; inline;
function VectorTableGetSize:LongWord; inline;
function VectorTableGetEntry(Number:LongWord):PtrUInt; inline;
function VectorTableSetEntry(Number:LongWord;Address:PtrUInt):LongWord; inline;

{==============================================================================}
{Exception Functions}
procedure HardwareException(AType:LongWord;Address,Frame:Pointer);
procedure UnhandledException(Obj:TObject;Addr:CodePointer;FrameCount:LongInt;Frames:PCodePointer);

{==============================================================================}
{Text IO Functions}
procedure TextIOOpen(var F:Text;AWrite:TTextIOWriteChar;ARead:TTextIOReadChar;AMode:LongInt;AUserData:Pointer);
procedure TextIOClose(var T:TextRec);
 
procedure TextIORead(var T:TextRec);
procedure TextIOWrite(var T:TextRec);
 
function TextIOReadData(ARead:TTextIOReadChar;AUserData:Pointer;ABuffer:PChar;ACount:LongInt):LongInt;

{==============================================================================}
{Console Functions}
function ConsoleWriteChar(ACh:Char;AUserData:Pointer):Boolean; inline;
function ConsoleReadChar(var ACh:Char;AUserData:Pointer):Boolean; inline;

function ConsoleHideMouse(AUserData:Pointer):Boolean; inline;
function ConsoleShowMouse(X,Y:LongWord;AUserData:Pointer):Boolean; inline;
function ConsoleReadMouse(var X,Y,Buttons:LongWord;AUserData:Pointer):Boolean; inline;

{==============================================================================}
{Name Functions}
function HostGetName:String; inline;
function HostSetName(const AName:String):Boolean; inline;
function HostGetDomain:String; inline;
function HostSetDomain(const ADomain:String):Boolean; inline;
 
{==============================================================================}
{Logging Functions}
procedure LoggingOutput(const AText:String); inline;
procedure LoggingOutputEx(AFacility,ASeverity:LongWord;const ATag,AContent:String); inline;

{==============================================================================}
{Utility Functions}
function FirstBitSet(Value:LongWord):LongWord; inline;
function CountLeadingZeros(Value:LongWord):LongWord; inline;

function PhysicalToIOAddress(Address:Pointer):LongWord; inline;
function IOAddressToPhysical(Address:Pointer):LongWord; inline;

function PhysicalToBusAddress(Address:Pointer):LongWord; inline;
function BusAddressToPhysical(Address:Pointer):LongWord; inline;

procedure NanosecondDelay(Nanoseconds:LongWord);
procedure MicrosecondDelay(Microseconds:LongWord);
procedure MillisecondDelay(Milliseconds:LongWord);

procedure NanosecondDelayEx(Nanoseconds:LongWord;Wait:Boolean);
procedure MicrosecondDelayEx(Microseconds:LongWord;Wait:Boolean);
procedure MillisecondDelayEx(Milliseconds:LongWord;Wait:Boolean);

{==============================================================================}
{RTL Functions}
function SysGetTickCount:DWORD;
function SysGetTickCount64:ULONGLONG;
procedure SysGetLocalTime(var SystemTime:TSystemTime);
function SysGetLocalTimeOffset:Integer;

{==============================================================================}
{Platform Helper Functions}
procedure PlatformLog(Level:LongWord;const AText:String);
procedure PlatformLogInfo(const AText:String);
procedure PlatformLogError(const AText:String);
procedure PlatformLogDebug(const AText:String);

{==============================================================================}
{==============================================================================}

implementation

{==============================================================================}
{==============================================================================}
var
 {Platform specific variables}
 DataAbortException:EDataAbort;
 PrefetchAbortException:EPrefetchAbort;
 UndefinedInstructionException:EUndefinedInstruction;
 
{==============================================================================}
{==============================================================================}
{Initialization Functions}
procedure PlatformInit;
{Initialize platform specific information for the current hardware}
begin
 {}
 {Check Initialized}
 if PlatformInitialized then Exit;

 {Initialize Logging}
 PLATFORM_LOG_ENABLED:=(PLATFORM_DEFAULT_LOG_LEVEL <> PLATFORM_LOG_LEVEL_NONE);
 IRQ_LOG_ENABLED:=(IRQ_DEFAULT_LOG_LEVEL <> IRQ_LOG_LEVEL_NONE); 
 FIQ_LOG_ENABLED:=(FIQ_DEFAULT_LOG_LEVEL <> FIQ_LOG_LEVEL_NONE); 
 SWI_LOG_ENABLED:=(SWI_DEFAULT_LOG_LEVEL <> SWI_LOG_LEVEL_NONE); 
 
 {Initialize CLOCK_FIQ_ENABLED}
 if not(FIQ_ENABLED) then CLOCK_FIQ_ENABLED:=False;
 
 {Initialize Clock Lock}
 ClockLock.Lock:=INVALID_HANDLE_VALUE;
 ClockLock.AcquireLock:=nil;
 ClockLock.ReleaseLock:=nil;

 {Initialize Power Lock}
 PowerLock.Lock:=INVALID_HANDLE_VALUE;
 PowerLock.AcquireLock:=nil;
 PowerLock.ReleaseLock:=nil;
 
 {Initialize Mailbox Lock}
 MailboxLock.Lock:=INVALID_HANDLE_VALUE;
 MailboxLock.AcquireLock:=nil;
 MailboxLock.ReleaseLock:=nil;

 {Initialize Shutdown Lock}
 ShutdownLock.Lock:=INVALID_HANDLE_VALUE;
 ShutdownLock.AcquireLock:=nil;
 ShutdownLock.ReleaseLock:=nil;
 
 {Initialize Interrupt Lock}
 InterruptLock.Lock:=INVALID_HANDLE_VALUE;
 InterruptLock.AcquireLock:=nil;
 InterruptLock.ReleaseLock:=nil;
 
 {Initialize Shutdown Semaphore}
 ShutdownSemaphore.Semaphore:=INVALID_HANDLE_VALUE;
 ShutdownSemaphore.WaitSemaphore:=nil;
 ShutdownSemaphore.SignalSemaphore:=nil;
 
 {Setup System Handlers}
 //To Do
 
 {Setup SysUtils Handlers}
 {Locale Functions}
 SysUtilsGetLocalTimeHandler:=SysGetLocalTime;
 SysUtilsGetLocalTimeOffsetHandler:=SysGetLocalTimeOffset;
 {Tick Functions}
 SysUtilsGetTickCountHandler:=SysGetTickCount;
 SysUtilsGetTickCount64Handler:=SysGetTickCount64;
 
 {Initialize CPU}
 CPUInit;
 
 {Initialize FPU}
 FPUInit;
 
 {Register the Memory Manager from HeapManager (Needs to happen before unit initialization}
 RegisterMemoryManager;
 
 {Setup the Initial Heap (Note that HeapManager will also set an initial heap based on FPC symbols __fpc_initialheap and __heapsize, this will be 256 bytes by default in BSS)}
 RegisterHeapBlock(Pointer(INITIAL_HEAP_BASE),INITIAL_HEAP_SIZE);

 {At this point we have an initial heap established and can use memory allocation etc}
 
 {Initialize GPU}
 GPUInit;
 
 {Initialize MMU}
 MMUInit;

 {Initialize SMP}
 SMPInit;
 
 {Initialize Cache}
 CacheInit;
 
 {Initialize Board}
 BoardInit;
 
 {Initialize Memory}
 MemoryInit;
 
 {Initialize Interrupts}
 InterruptInit;
 
 {Initialize Clock}
 ClockInit;
 
 {Parse the Boot Tags}
 ParseBootTags;
 
 {Parse the Command Line}
 ParseCommandLine;

 {Parse the Environment}
 ParseEnvironment;

 {Initialize Mailbox Access}
 MailboxInit;
 
 {Initialize Power Management}
 PowerInit;

 {Initialize Peripheral Access}
 PeripheralInit;
 
 {Initialize Hardware Exceptions}
 DataAbortException:=EDataAbort.Create(STRING_DATA_ABORT);
 PrefetchAbortException:=EPrefetchAbort.Create(STRING_PREFETCH_ABORT);
 UndefinedInstructionException:=EUndefinedInstruction.Create(STRING_UNDEFINED_INSTRUCTION);
 
 {Initialize Unhandled Exceptions}
 ExceptProc:=@UnhandledException;
 
 PlatformInitialized:=True; 
end;

{==============================================================================}

procedure CPUInit;
{Initialize the CPU including performance features etc (Where Applicable)}
begin
 {}
 {Check Initialized}
 if CPUInitialized then Exit;
 
 {Check the Handler}
 if Assigned(CPUInitHandler) then
  begin
   {Call the Handler}
   CPUInitHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
  
 CPUInitialized:=True;
end;

{==============================================================================}

procedure FPUInit;
{Initialize the Floating Point Processor Unit (Where Applicable)}
begin
 {}
 {Check Initialized}
 if FPUInitialized then Exit;
 
 {Check the Handler}
 if Assigned(FPUInitHandler) then
  begin
   {Call the Handler}
   FPUInitHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
 
 FPUInitialized:=True;
end;

{==============================================================================}

procedure GPUInit;
{Initialize the Graphics Processor Unit (Where Applicable)}
begin
 {}
 {Check Initialized}
 if GPUInitialized then Exit;
 
 {Check the Handler}
 if Assigned(GPUInitHandler) then
  begin
   {Call the Handler}
   GPUInitHandler;
  end;

 {Perform default initialization}
  {Nothing} 
  
 GPUInitialized:=True;
end;

{==============================================================================}

procedure MMUInit;
{Initialize the Memory Management Unit (Where Applicable)}
begin
 {}
 {Check Initialized}
 if MMUInitialized then Exit;
 
 {Check the Handler}
 if Assigned(MMUInitHandler) then
  begin
   {Call the Handler}
   MMUInitHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
 
 MMUInitialized:=True;
end;

{==============================================================================}

procedure SMPInit;
{Initialize the Symetric Multi Processor support (Where Applicable)}
{Note: Secondary CPU boot is performed by SecondaryInit in Threads}
begin
 {}
 {Check Initialized}
 if SMPInitialized then Exit;
 
 {Check the Handler}
 if Assigned(SMPInitHandler) then
  begin
   {Call the Handler}
   SMPInitHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
 
 SMPInitialized:=True;
end;

{==============================================================================}

procedure CacheInit;
{Initialize CPU Data and Instruction Caching (Where Applicable)}
begin
 {}
 {Check Initialized}
 if CacheInitialized then Exit;
 
 {Check the Handler}
 if Assigned(CacheInitHandler) then
  begin
   {Call the Handler}
   CacheInitHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
 
 CacheInitialized:=True;
end;

{==============================================================================}

procedure BoardInit;
{Initialize Board specific information (Where Applicable)}
begin
 {}
 {Check Initialized}
 if BoardInitialized then Exit;
 
 {Check the Handler}
 if Assigned(BoardInitHandler) then
  begin
   {Call the Handler}
   BoardInitHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
 
 BoardInitialized:=True;
end;

{==============================================================================}

procedure MemoryInit;
{Initialize Memory specific information (Where Applicable)}
begin
 {}
 {Check Initialized}
 if MemoryInitialized then Exit;
 
 {Check the Handler}
 if Assigned(MemoryInitHandler) then
  begin
   {Call the Handler}
   MemoryInitHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
 
 MemoryInitialized:=True;
end;

{==============================================================================}

procedure ClockInit;
{Initialize the Clock handling}
begin
 {}
 {Check Initialized}
 if ClockInitialized then Exit;
 
 {Check the Handler}
 if Assigned(ClockInitHandler) then
  begin
   {Call the Handler}
   ClockInitHandler;
  end;
  
 {Perform default initialization}
  {Nothing} 
  
 ClockInitialized:=True;
end;

{==============================================================================}

procedure PowerInit;
{Initialize Power management (Where Applicable)}
begin
 {}
 {Check Initialized}
 if PowerInitialized then Exit;

 {Check the Handler}
 if Assigned(PowerInitHandler) then
  begin
   {Call the Handler}
   PowerInitHandler;
  end;

 {Perform default initialization}
  {Nothing} 
  
 PowerInitialized:=True;
end;

{==============================================================================}

procedure MailboxInit;
{Initialize Mailbox access (Where Applicable)} 
begin
 {}
 {Check Initialized}
 if MailboxInitialized then Exit;

 {Check the Handler}
 if Assigned(MailboxInitHandler) then
  begin
   {Call the Handler}
   MailboxInitHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
 
 MailboxInitialized:=True;
end;

{==============================================================================}

procedure InterruptInit;
{Initialize Interrupt handling}
begin
 {}
 {Check Initialized}
 if InterruptsInitialized then Exit;

 {Check the Handler}
 if Assigned(InterruptInitHandler) then
  begin
   {Call the Handler}
   InterruptInitHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
 
 InterruptsInitialized:=True;
end;

{==============================================================================}

procedure PeripheralInit;
{Initialize Peripheral devices (Where Applicable)}
begin
 {}
 {Check Initialized}
 if PeripheralsInitialized then Exit;

 {Check the Handler}
 if Assigned(PeripheralInitHandler) then
  begin
   {Call the Handler}
   PeripheralInitHandler;
  end;

 {Perform default initialization}
  {Nothing} 
  
 PeripheralsInitialized:=True;
end;

{==============================================================================}

procedure ParseBootTags;
{Parse any boot tag information passed by the bootloader (Where Applicable)}
begin
 {}
 {Check Completed}
 if ParseBootTagsCompleted then Exit;

 {Check the Handler}
 if Assigned(ParseBootTagsHandler) then
  begin
   {Call the Handler}
   ParseBootTagsHandler;
  end;
  
 {Perform default initialization}
  {Nothing} 
  
 ParseBootTagsCompleted:=True; 
end;

{==============================================================================}

procedure ParseCommandLine;
{Setup argc, argv and cmdline and process known command line options (Where Applicable)}
begin
 {}
 {Check Completed}
 if ParseCommandLineCompleted then Exit;
 
 {Check the Handler}
 if Assigned(ParseCommandLineHandler) then
  begin
   {Call the Handler}
   ParseCommandLineHandler;
  end;
 
 {Perform default initialization}
  {Nothing} 
 
 ParseCommandLineCompleted:=True; 
end;

{==============================================================================}

procedure ParseEnvironment;
{Setup envp and process known environment options (Where Applicable)}
var
 WorkInt:LongWord;
begin
 {}
 {Check Completed}
 if ParseEnvironmentCompleted then Exit;
 
 {Check the Handler}
 if Assigned(ParseEnvironmentHandler) then
  begin
   {Call the Handler}
   ParseEnvironmentHandler;
  end;
 
 {Perform default initialization}
 {TIMER_THREAD_COUNT}
 WorkInt:=StrToIntDef(SysUtils.GetEnvironmentVariable('TIMER_THREAD_COUNT'),0);
 if WorkInt > 0 then TIMER_THREAD_COUNT:=WorkInt;
  
 {WORKER_THREAD_COUNT}
 WorkInt:=StrToIntDef(SysUtils.GetEnvironmentVariable('WORKER_THREAD_COUNT'),0);
 if WorkInt > 0 then WORKER_THREAD_COUNT:=WorkInt;
 
 //To Do
 
 ParseEnvironmentCompleted:=True; 
end;

{==============================================================================}
{==============================================================================}
{EHardwareException}
procedure EHardwareException.FreeInstance;
begin
 {}
 if AllowFree then inherited FreeInstance;
end;

{==============================================================================}
{==============================================================================}
{Boot Functions}
procedure BootBlink; inline;
{Blink the Activity LED (Where Applicable)}
{Note: Intended for startup diagnostics when bootstrapping a new board}
begin
 {}
 if Assigned(BootBlinkHandler) then
  begin
   BootBlinkHandler;
  end;
end;

{==============================================================================}
{==============================================================================}
{LED Functions}
procedure PowerLEDEnable; inline;
{Enable the Power LED (Where Applicable)}
begin
 {}
 if Assigned(PowerLEDEnableHandler) then
  begin
   PowerLEDEnableHandler;
  end;
end;

{==============================================================================}

procedure PowerLEDOn; inline;
{Turn On the Power LED (Where Applicable)}
begin
 {}
 if Assigned(PowerLEDOnHandler) then
  begin
   PowerLEDOnHandler;
  end;
end;

{==============================================================================}

procedure PowerLEDOff; inline;
{Turn Off the Power LED (Where Applicable)}
begin
 {}
 if Assigned(PowerLEDOffHandler) then
  begin
   PowerLEDOffHandler;
  end;
end;

{==============================================================================}

procedure ActivityLEDEnable; inline;
{Enable the Activity LED (Where Applicable)}
begin
 {}
 if Assigned(ActivityLEDEnableHandler) then
  begin
   ActivityLEDEnableHandler;
  end;
end;

{==============================================================================}

procedure ActivityLEDOn; inline;
{Turn On the Activity LED (Where Applicable)}
begin
 {}
 if Assigned(ActivityLEDOnHandler) then
  begin
   ActivityLEDOnHandler;
  end;
end;

{==============================================================================}

procedure ActivityLEDOff; inline;
{Turn Off the Activity LED (Where Applicable)}
begin
 {}
 if Assigned(ActivityLEDOffHandler) then
  begin
   ActivityLEDOffHandler;
  end;
end;

{==============================================================================}
{==============================================================================}
{Mailbox Functions}
function MailboxReceive(Mailbox,Channel:LongWord):LongWord; inline;
{Receive from specifed mailbox on specified channel}
begin
 {}
 if Assigned(MailboxReceiveHandler) then
  begin
   Result:=MailboxReceiveHandler(Mailbox,Channel);
  end
 else
  begin
   Result:=0;
  end;  
end;

{==============================================================================}

procedure MailboxSend(Mailbox,Channel,Data:LongWord); inline;
{Send to specifed mailbox on specified channel}
begin
 {}
 if Assigned(MailboxSendHandler) then
  begin
   MailboxSendHandler(Mailbox,Channel,Data);
  end;
end;

{==============================================================================}

function MailboxCall(Mailbox,Channel,Data:LongWord;var Response:LongWord):LongWord; inline;
{Perform a transaction (Send/Receive) to specifed mailbox on specified channel}
begin
 {}
 if Assigned(MailboxCallHandler) then
  begin
   Result:=MailboxCallHandler(Mailbox,Channel,Data,Response);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function MailboxCallEx(Mailbox,Channel,Data:LongWord;var Response:LongWord;Timeout:LongWord):LongWord; inline;
{Perform a transaction (Send/Receive) to specifed mailbox on specified channel}
begin
 {}
 if Assigned(MailboxCallExHandler) then
  begin
   Result:=MailboxCallExHandler(Mailbox,Channel,Data,Response,Timeout);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function MailboxPropertyCall(Mailbox,Channel:LongWord;Data:Pointer;var Response:LongWord):LongWord; inline;
{Perform a property tag transaction (Send/Receive) to specifed mailbox on specified channel}
begin
 {}
 if Assigned(MailboxPropertyCallHandler) then
  begin
   Result:=MailboxPropertyCallHandler(Mailbox,Channel,Data,Response);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function MailboxPropertyCallEx(Mailbox,Channel:LongWord;Data:Pointer;var Response:LongWord;Timeout:LongWord):LongWord; inline;
{Perform a property tag transaction (Send/Receive) to specifed mailbox on specified channel}
begin
 {}
 if Assigned(MailboxPropertyCallExHandler) then
  begin
   Result:=MailboxPropertyCallExHandler(Mailbox,Channel,Data,Response,Timeout);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
{==============================================================================}
{Random Number Functions}
function RandomAvailable:Boolean; inline;
{Check if a hardware random number generator is currently available}
{The software random number generator from the RTL is always available}
begin
 {}
 if Assigned(RandomAvailableHandler) then
  begin
   Result:=RandomAvailableHandler;
  end
 else
  begin
   Result:=False;
  end;
end;

{==============================================================================}

procedure RandomSeed(Seed:LongWord); inline;
begin
 {}
 if Assigned(RandomSeedHandler) then
  begin
   RandomSeedHandler(Seed);
  end;
end;

{==============================================================================}

function RandomReadLongInt(Limit:LongInt):LongInt; inline;
begin
 {}
 if Assigned(RandomReadLongIntHandler) then
  begin
   Result:=RandomReadLongIntHandler(Limit);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function RandomReadInt64(Limit:Int64):Int64; inline;
begin
 {}
 if Assigned(RandomReadInt64Handler) then
  begin
   Result:=RandomReadInt64Handler(Limit);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function RandomReadExtended:Extended; inline;
begin
 {}
 if Assigned(RandomReadExtendedHandler) then
  begin
   Result:=RandomReadExtendedHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}
{==============================================================================}
{Watchdog Timer Functions}
function WatchdogAvailable:Boolean; inline; 
{Check if a watchdog timer is currently available}
begin
 {}
 if Assigned(WatchdogAvailableHandler) then
  begin
   Result:=WatchdogAvailableHandler;
  end
 else
  begin
   Result:=False;
  end;
end;

{==============================================================================}

function WatchdogStart(Milliseconds:LongWord):LongWord; inline;
begin
 {}
 if Assigned(WatchdogStartHandler) then
  begin
   Result:=WatchdogStartHandler(Milliseconds);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function WatchdogStop:LongWord; inline;
begin
 {}
 if Assigned(WatchdogStopHandler) then
  begin
   Result:=WatchdogStopHandler;
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function WatchdogRefresh(Milliseconds:LongWord):LongWord; inline;
begin
 {}
 if Assigned(WatchdogRefreshHandler) then
  begin
   Result:=WatchdogRefreshHandler(Milliseconds);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
{==============================================================================}
{Interrupt Request (IRQ) Functions}
function RequestIRQ(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord; inline;
{Request registration of the supplied handler to the specified IRQ number}
{Note: If the IRQ number is already registered then the request will fail}
begin
 {}
 if Assigned(RequestIRQHandler) then
  begin
   Result:=RequestIRQHandler(CPUID,Number,Handler,Parameter);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function ReleaseIRQ(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord; inline;
{Request deregistration of the supplied handler from the specified IRQ number}
{Note: If the IRQ number is not currently registered then the request will fail}
begin
 {}
 if Assigned(ReleaseIRQHandler) then
  begin
   Result:=ReleaseIRQHandler(CPUID,Number,Handler,Parameter);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function RequestExIRQ(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord; inline;
{Request registration of the supplied extended handler to the specified IRQ number}
{Note: If the IRQ number is already registered then the request will fail}
begin
 {}
 if Assigned(RequestExIRQHandler) then
  begin
   Result:=RequestExIRQHandler(CPUID,Number,Handler,HandlerEx,Parameter);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function ReleaseExIRQ(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord; inline;
{Request deregistration of the supplied extended handler from the specified IRQ number}
{Note: If the IRQ number is not currently registered then the request will fail}
begin
 {}
 if Assigned(ReleaseExIRQHandler) then
  begin
   Result:=ReleaseExIRQHandler(CPUID,Number,Handler,HandlerEx,Parameter);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
{==============================================================================}
{Fast Interrupt Request (FIQ) Functions}
function RequestFIQ(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord; inline;
{Request registration of the supplied handler to the specified FIQ number}
{Note: If the FIQ number is already registered then the request will fail}
begin
 {}
 if Assigned(RequestFIQHandler) then
  begin
   Result:=RequestFIQHandler(CPUID,Number,Handler,Parameter);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function ReleaseFIQ(CPUID,Number:LongWord;Handler:TInterruptHandler;Parameter:Pointer):LongWord; inline;
{Request deregistration of the supplied handler from the specified FIQ number}
{Note: If the FIQ number is not currently registered then the request will fail}
begin
 {}
 if Assigned(ReleaseFIQHandler) then
  begin
   Result:=ReleaseFIQHandler(CPUID,Number,Handler,Parameter);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function RequestExFIQ(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord; inline;
{Request registration of the supplied extended handler to the specified FIQ number}
{Note: If the FIQ number is already registered then the request will fail}
begin
 {}
 if Assigned(RequestExFIQHandler) then
  begin
   Result:=RequestExFIQHandler(CPUID,Number,Handler,HandlerEx,Parameter);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function ReleaseExFIQ(CPUID,Number:LongWord;Handler:TInterruptHandler;HandlerEx:TInterruptExHandler;Parameter:Pointer):LongWord; inline;
{Request deregistration of the supplied extended handler from the specified FIQ number}
{Note: If the FIQ number is not currently registered then the request will fail}
begin
 {}
 if Assigned(ReleaseExFIQHandler) then
  begin
   Result:=ReleaseExFIQHandler(CPUID,Number,Handler,HandlerEx,Parameter);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
{==============================================================================}
{System Functions}
function SystemRestart(Delay:LongWord):LongWord; inline;
{Restart the system}
begin
 {}
 if Assigned(SystemRestartHandler) then
  begin
   //To Do //Transfer to Worker
   
   //To Do //Implement Delay (by Worker)
   
   //To Do //Call Shutdown handlers (Worker with Callback using Semaphore)
   
   Result:=SystemRestartHandler(Delay); //To Do //Pass default delay
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function SystemShutdown(Delay:LongWord):LongWord; inline;
{Shutdown the system}
begin
 {}
 if Assigned(SystemShutdownHandler) then
  begin
   //To Do //Transfer to Worker
   
   //To Do //Implement Delay (by Worker)
  
   //To Do //Call Shutdown handlers (Worker with Callback using Semaphore)
   
   Result:=SystemShutdownHandler(Delay); //To Do //Pass default delay
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function SystemGetUptime:Int64; inline;
{Get the current system up time in 100 nanosecond ticks since 1/1/1601}
{Return: The current system up time}
{Note: This is the same time format as Windows FILE_TIME and is intended to allow
 compatibility with file system functions etc.}
begin
 {}
 if Assigned(SystemGetUptimeHandler) then
  begin
   Result:=SystemGetUptimeHandler;
  end
 else
  begin
   {Get Current Seconds}
   Result:=ClockSeconds; {Avoid 32 bit overflow}
   {Get Current Up Time}
   Result:=TIME_TICKS_TO_1899 + (Result * TIME_TICKS_PER_SECOND);
  end;  
end;

{==============================================================================}

function SystemGetCommandLine:String; inline;
{Get the current command line}
begin
 {}
 if Assigned(SystemGetCommandLineHandler) then
  begin
   Result:=SystemGetCommandLineHandler;
  end
 else
  begin
   if cmdline = nil then Result:='' else Result:=StrPas(cmdline);
  end;
end;

{==============================================================================}

function SystemGetEnvironment:Pointer; inline;
{Get the current environment}
begin
 {}
 if Assigned(SystemGetEnvironmentHandler) then
  begin
   Result:=SystemGetEnvironmentHandler;
  end
 else
  begin
   Result:=envp;
  end;
end;

{==============================================================================}

procedure SystemCall(Number:LongWord;Param1,Param2,Param3:PtrUInt); inline;
{Perform a System Call function with the supplied parameters (Where Applicable)}
begin
 {}
 if Assigned(SystemCallHandler) then
  begin
   SystemCallHandler(Number,Param1,Param2,Param3);
  end;
end;

{==============================================================================}
{==============================================================================}
{CPU Functions}
function CPUGetType:LongWord; inline;
{Get the CPU type for this board}
begin
 {}
 if Assigned(CPUGetTypeHandler) then
  begin
   Result:=CPUGetTypeHandler;
  end
 else
  begin
   Result:=CPU_TYPE;
  end;
end;

{==============================================================================}

function CPUGetBoot:LongWord; inline;
{Get the boot CPU for this board}
begin
 {}
 if Assigned(CPUGetBootHandler) then
  begin
   Result:=CPUGetBootHandler;
  end
 else
  begin
   Result:=CPU_BOOT;
  end;
end;

{==============================================================================}

function CPUGetMask:LongWord; inline;
{Get the CPU mask for this board}
begin
 {}
 if Assigned(CPUGetMaskHandler) then
  begin
   Result:=CPUGetMaskHandler;
  end
 else
  begin
   Result:=CPU_MASK;
  end;
end;

{==============================================================================}

function CPUGetCount:LongWord; inline;
{Get the CPU count for this board}
begin
 {}
 if Assigned(CPUGetCountHandler) then
  begin
   Result:=CPUGetCountHandler;
  end
 else
  begin
   Result:=CPU_COUNT;
  end;
end;

{==============================================================================}

function CPUGetMode:LongWord; inline;
{Get the current CPU mode}
{Note: The return value is specific to the CPU type}
begin
 {}
 if Assigned(CPUGetModeHandler) then
  begin
   Result:=CPUGetModeHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function CPUGetState:LongWord; inline;
{Get the current CPU state}
begin
 {}
 if Assigned(CPUGetStateHandler) then
  begin
   Result:=CPUGetStateHandler;
  end
 else
  begin
   Result:=CPU_STATE_NONE;
  end;
end;

{==============================================================================}

function CPUGetCurrent:LongWord; inline;
{Get the current CPU ID}
begin
 {}
 if Assigned(CPUGetCurrentHandler) then
  begin
   Result:=CPUGetCurrentHandler;
  end
 else
  begin
   Result:=CPU_ID_0;
  end;
end;

{==============================================================================}

function CPUGetMemory(var Address:PtrUInt;var Length:LongWord):LongWord; inline; 
{Get the memory start and size available to the CPU}
begin
 {}
 if Assigned(CPUGetMemoryHandler) then
  begin
   Result:=CPUGetMemoryHandler(Address,Length);
  end
 else
  begin
   Address:=CPU_MEMORY_BASE;
   Length:=CPU_MEMORY_SIZE;
   
   Result:=ERROR_SUCCESS;
  end;  
end;

{==============================================================================}

function CPUGetPercentage(CPUID:LongWord):Double; inline;
{Get the last second ulitization of the specified CPU in percentage}
{CPUID: The CPU to get utilization from or CPU_ID_ALL for average of all CPUs}
var
 Count:LongWord;
 Total:LongWord;
 Utilization:LongWord;
begin
 {}
 Result:=0;
 
 {Check CPU}
 if (CPUID <> CPU_ID_ALL) and (CPUID > (CPUGetCount - 1)) then Exit;
 
 {Check Handler}
 if Assigned(CPUGetPercentageHandler) then
  begin
   {Use the Handler method}
   Result:=CPUGetPercentageHandler(CPUID);
  end
 else
  begin
   {Use the Default method}
   if CPUID <> CPU_ID_ALL then
    begin
     {Get Utilization}
     Utilization:=UtilizationLast[CPUID];
     
     {Get Percentage}
     Result:=(Utilization / SCHEDULER_IDLE_PER_SECOND) * 100;
    end
   else
    begin
     {Get CPU Count}
     Total:=CPUGetCount;
     Utilization:=0;
     for Count:=0 to Total - 1 do
      begin
       {Get CPU Utilization} 
       Utilization:=Utilization + UtilizationLast[Count];
      end;
      
     {Get CPU Average} 
     Utilization:=Utilization div Total; 
     
     {Get Percentage}
     Result:=(Utilization / SCHEDULER_IDLE_PER_SECOND) * 100;
    end;
  end;  
end;

{==============================================================================}

function CPUGetUtilization(CPUID:LongWord):LongWord; inline;
{Get the last second ulitization of the specified CPU}
{CPUID: The CPU to get utilization from or CPU_ID_ALL for average of all CPUs}
var
 Count:LongWord;
 Total:LongWord;
 Utilization:LongWord;
begin
 {}
 Result:=0;
 
 {Check CPU}
 if (CPUID <> CPU_ID_ALL) and (CPUID > (CPUGetCount - 1)) then Exit;
 
 {Check Handler}
 if Assigned(CPUGetUtilizationHandler) then
  begin
   {Use the Handler method}
   Result:=CPUGetUtilizationHandler(CPUID);
  end
 else
  begin
   {Use the Default method}
   if CPUID <> CPU_ID_ALL then
    begin
     Result:=UtilizationLast[CPUID];
    end
   else
    begin
     {Get CPU Count}
     Total:=CPUGetCount;
     Utilization:=0;
     for Count:=0 to Total - 1 do
      begin
       {Get CPU Utilization} 
       Utilization:=Utilization + UtilizationLast[Count];
      end;
      
     {Get CPU Average} 
     Result:=Utilization div Total; 
    end;
  end;  
end;

{==============================================================================}

function CPUGetModel:LongWord; inline;
{Get the CPU model of the current CPU}
begin
 {}
 if Assigned(CPUGetModelHandler) then
  begin
   Result:=CPUGetModelHandler;
  end
 else
  begin
   Result:=CPU_MODEL_UNKNOWN;
  end;
end;

{==============================================================================}

function CPUGetRevision:LongWord; inline;
{Get the CPU revision of the current CPU}
{Note: The return value is specific to the CPU type and model}
begin
 {}
 if Assigned(CPUGetRevisionHandler) then
  begin
   Result:=CPUGetRevisionHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function CPUGetDescription:String; inline;
{Get the CPU description of the current CPU}
begin
 {}
 if Assigned(CPUGetDescriptionHandler) then
  begin
   Result:=CPUGetDescriptionHandler;
  end
 else
  begin
   Result:='';
  end;
end;

{==============================================================================}
{==============================================================================}
{FPU Functions}
function FPUGetType:LongWord; inline;
{Get the FPU type for this board}
begin
 {}
 if Assigned(FPUGetTypeHandler) then
  begin
   Result:=FPUGetTypeHandler;
  end
 else
  begin
   Result:=FPU_TYPE;
  end;
end;

{==============================================================================}

function FPUGetState:LongWord; inline;
{Get the current FPU state}
begin
 {}
 if Assigned(FPUGetStateHandler) then
  begin
   Result:=FPUGetStateHandler;
  end
 else
  begin
   Result:=FPU_STATE_NONE;
  end;
end;

{==============================================================================}
{==============================================================================}
{GPU Functions}
function GPUGetType:LongWord; inline;
{Get the GPU type for this board}
begin
 {}
 if Assigned(GPUGetTypeHandler) then
  begin
   Result:=GPUGetTypeHandler;
  end
 else
  begin
   Result:=GPU_TYPE;
  end;
end;

{==============================================================================}

function GPUGetState:LongWord; inline;
{Get the current GPU state}
begin
 {}
 if Assigned(GPUGetStateHandler) then
  begin
   Result:=GPUGetStateHandler;
  end
 else
  begin
   Result:=GPU_STATE_NONE;
  end;
end;

{==============================================================================}

function GPUGetMemory(var Address:PtrUInt;var Length:LongWord):LongWord; inline; 
{Get the memory start and size available to the GPU}
begin
 {}
 if Assigned(GPUGetMemoryHandler) then
  begin
   Result:=GPUGetMemoryHandler(Address,Length);
  end
 else
  begin
   Address:=GPU_MEMORY_BASE;
   Length:=GPU_MEMORY_SIZE;
   
   Result:=ERROR_SUCCESS;
  end;  
end;

{==============================================================================}
{==============================================================================}
{Cache Functions}
function L1CacheGetType:LongWord; inline; 
{Get the L1 cache type for this board}
begin
 {}
 if Assigned(L1CacheGetTypeHandler) then
  begin
   Result:=L1CacheGetTypeHandler;
  end
 else
  begin
   Result:=CACHE_TYPE_NONE;
  end;
end;

{==============================================================================}

function L1DataCacheGetSize:LongWord; inline; 
{Get the L1 data cache size for this board}
{Note: If data cache is not supported, the size returned is zero}
{Note: If separate data and instruction caches are not supported, the size returned is the unified size}
begin
 {}
 if Assigned(L1DataCacheGetSizeHandler) then
  begin
   Result:=L1DataCacheGetSizeHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function L1DataCacheGetLineSize:LongWord; inline; 
{Get the L1 data cache line size for this board}
{Note: If data cache is not supported, the size returned is zero}
{Note: If separate data and instruction caches are not supported, the size returned is the unified size}
begin
 {}
 if Assigned(L1DataCacheGetLineSizeHandler) then
  begin
   Result:=L1DataCacheGetLineSizeHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function L1InstructionCacheGetSize:LongWord; inline; 
{Get the L1 instruction cache size for this board}
{Note: If instruction cache is not supported, the size returned is zero}
{Note: If separate data and instruction caches are not supported, the size returned is the unified size}
begin
 {}
 if Assigned(L1InstructionCacheGetSizeHandler) then
  begin
   Result:=L1InstructionCacheGetSizeHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function L1InstructionCacheGetLineSize:LongWord; inline; 
{Get the L1 instruction cache line size for this board}
{Note: If instruction cache is not supported, the size returned is zero}
{Note: If separate data and instruction caches are not supported, the size returned is the unified size}
begin
 {}
 if Assigned(L1InstructionCacheGetLineSizeHandler) then
  begin
   Result:=L1InstructionCacheGetLineSizeHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function L2CacheGetType:LongWord; inline; 
{Get the L2 cache type for this board}
begin
 {}
 if Assigned(L2CacheGetTypeHandler) then
  begin
   Result:=L2CacheGetTypeHandler;
  end
 else
  begin
   Result:=CACHE_TYPE_NONE;
  end;
end;

{==============================================================================}

function L2CacheGetSize:LongWord; inline; 
{Get the L2 cache size for this board}
{Note: If L2 cache is not supported, the size returned is zero}
begin
 {}
 if Assigned(L2CacheGetSizeHandler) then
  begin
   Result:=L2CacheGetSizeHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function L2CacheGetLineSize:LongWord; inline; 
{Get the L2 cache line size for this board}
{Note: If L2 cache is not supported, the size returned is zero}
begin
 {}
 if Assigned(L2CacheGetLineSizeHandler) then
  begin
   Result:=L2CacheGetLineSizeHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}
{==============================================================================}
{Board Functions}
function BoardGetType:LongWord; inline;
{Get the current Board type}
begin
 {}
 if Assigned(BoardGetTypeHandler) then
  begin
   Result:=BoardGetTypeHandler;
  end
 else
  begin
   Result:=BOARD_TYPE;
  end;
end;

{==============================================================================}

function BoardGetModel:LongWord; inline;
{Get the current Board model}
begin
 {}
 if Assigned(BoardGetModelHandler) then
  begin
   Result:=BoardGetModelHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function BoardGetSerial:Int64; inline;
{Get the current Board serial number}
begin
 {}
 if Assigned(BoardGetSerialHandler) then
  begin
   Result:=BoardGetSerialHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function BoardGetRevision:LongWord; inline;
{Get the current Board revision number}
begin
 {}
 if Assigned(BoardGetRevisionHandler) then
  begin
   Result:=BoardGetRevisionHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function BoardGetMACAddress:String; inline;
{Get the current Board MAC address (Where Applicable)}
begin
 {}
 if Assigned(BoardGetMACAddressHandler) then
  begin
   Result:=BoardGetMACAddressHandler;
  end
 else
  begin
   Result:='';
  end;
end;

{==============================================================================}
{==============================================================================}
{Firmware Functions}
function FirmwareGetRevision:LongWord; inline;
{Get the current board Firmware Revision}
begin
 {}
 if Assigned(FirmwareGetRevisionHandler) then
  begin
   Result:=FirmwareGetRevisionHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}
{==============================================================================}
{Machine Functions}
function MachineGetType:LongWord; inline;
{Get the current Machine type}
begin
 {}
 if Assigned(MachineGetTypeHandler) then
  begin
   Result:=MachineGetTypeHandler;
  end
 else
  begin
   Result:=MACHINE_TYPE;
  end;
end;

{==============================================================================}
{==============================================================================}
{Memory Functions}
function MemoryGetBase:PtrUInt; inline;
{Get the base address of system memory}
begin
 {}
 if Assigned(MemoryGetBaseHandler) then
  begin
   Result:=MemoryGetBaseHandler;
  end
 else
  begin
   Result:=MEMORY_BASE;
  end;
end;

{==============================================================================}

function MemoryGetSize:LongWord; inline;
{Get the total size of system memory}
begin
 {}
 if Assigned(MemoryGetSizeHandler) then
  begin
   Result:=MemoryGetSizeHandler;
  end
 else
  begin
   Result:=MEMORY_SIZE;
  end;
end;

{==============================================================================}

function MemoryGetPageSize:LongWord; inline;
{Get the page size of system memory}
begin
 {}
 if Assigned(MemoryGetPageSizeHandler) then
  begin
   Result:=MemoryGetPageSizeHandler;
  end
 else
  begin
   Result:=MEMORY_PAGE_SIZE;
  end;
end;

{==============================================================================}

function MemoryGetLargePageSize:LongWord; inline;
{Get the large page size of system memory (Where Applicable)}
begin
 {}
 if Assigned(MemoryGetLargePageSizeHandler) then
  begin
   Result:=MemoryGetLargePageSizeHandler;
  end
 else
  begin
   Result:=MEMORY_LARGEPAGE_SIZE;
  end;
end;

{==============================================================================}
{==============================================================================}
{Power Functions}
function PowerOn(PowerId:LongWord):LongWord;
{Power On the specified device}
var
 State:LongWord;
begin
 {}
 State:=PowerGetState(PowerId);
 if State = POWER_STATE_OFF then
  begin
   Result:=PowerSetState(PowerId,POWER_STATE_ON,True);
  end
 else
  begin
   Result:=ERROR_SUCCESS;
  end;  
end;

{==============================================================================}

function PowerOff(PowerId:LongWord):LongWord;
{Power Off the specified device}
var
 State:LongWord;
begin
 {}
 State:=PowerGetState(PowerId);
 if State = POWER_STATE_ON then
  begin
   Result:=PowerSetState(PowerId,POWER_STATE_OFF,True);
  end
 else
  begin
   Result:=ERROR_SUCCESS;
  end;  
end;

{==============================================================================}

function PowerGetWait(PowerId:LongWord):LongWord; inline;
{Get the enable wait time in Microseconds of the specified device}
begin
 {}
 if Assigned(PowerGetWaitHandler) then
  begin
   Result:=PowerGetWaitHandler(PowerId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function PowerGetState(PowerId:LongWord):LongWord; inline;
{Get the power state of the specified device}
begin
 {}
 if Assigned(PowerGetStateHandler) then
  begin
   Result:=PowerGetStateHandler(PowerId);
  end
 else
  begin
   Result:=POWER_STATE_OFF;
  end;
end;

{==============================================================================}

function PowerSetState(PowerId,State:LongWord;Wait:Boolean):LongWord; inline;
{Set the power state of the specified device (Optionally waiting for ready)}
begin
 {}
 if Assigned(PowerSetStateHandler) then
  begin
   Result:=PowerSetStateHandler(PowerId,State,Wait);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
{==============================================================================}
{Clock Functions}
function ClockGetTime:Int64;
{Get the current system time in 100 nanosecond ticks since 1/1/1601}
{Return: The current system time}
{Note: This is the same time format as Windows FILE_TIME and is intended to allow
       compatibility with file system functions etc.}
{Note: By default the time returned by this function is considered to be UTC but
 the actual conversion between UTC and local time is handled at a higher level}
begin
 {}
 {Get Current Seconds}
 Result:=ClockSeconds; {Avoid 32 bit overflow}
 
 {Get Current Time}
 Result:=ClockBase + (Result * TIME_TICKS_PER_SECOND);
 
 //To Do //Add RTC support //RTCAvailable/RTCGetTime etc //Initialization of clock as well
end;

{==============================================================================}

function ClockSetTime(const Time:Int64):LongWord;
{Set the current system time in 100 nanosecond ticks since 1/1/1601}
{Time: The time to be set}
{Return: The system time after setting}
{Note: This is the same time format as Windows FILE_TIME and is intended to allow
       compatibility with file system functions etc.}
{Note: By default the time passed to this function is considered to be UTC but
 the actual conversion between UTC and local time is handled at a higher level}
var
 CurrentSeconds:Int64;
begin
 {}
 {Acquire Lock}
 if ClockLock.Lock <> INVALID_HANDLE_VALUE then ClockLock.AcquireLock(ClockLock.Lock);
 
 {Get Current Seconds}
 CurrentSeconds:=ClockSeconds; {Avoid 32 bit overflow}
 
 {Get Current Time}
 CurrentSeconds:=(CurrentSeconds * TIME_TICKS_PER_SECOND);
 
 {Check Time}
 if Time < CurrentSeconds then
  begin
   {Set Current Time}
   ClockBase:=0;
   
   {Get Current Time}
   Result:=ClockBase + CurrentSeconds;
  end
 else
  begin 
   {Set Current Time}
   ClockBase:=(Time - CurrentSeconds); 
   
   {Get Current Time}
   Result:=ClockBase + CurrentSeconds;
  end; 
  
 {Release Lock}
 if ClockLock.Lock <> INVALID_HANDLE_VALUE then ClockLock.ReleaseLock(ClockLock.Lock);
 
 //To Do //Add RTC support //RTCAvailable/RTCSetTime
end;

{==============================================================================}

function ClockGetCount:LongWord; inline;
{Gets the current system clock count (32 least significant bits of total)}
{Note: This will normally come from the free running system timer in the board
 and is useful as a form of tick count but not for time keeping because
 the actual rate at which this increments is dependant on the system timer clock
 frequency of the specific board and may not be a measure of time in its raw form}
begin
 {} 
 if Assigned(ClockGetCountHandler) then
  begin
   Result:=ClockGetCountHandler;
  end
 else
  begin
   Result:=0;
  end;
end;
 
{==============================================================================}

function ClockGetTotal:Int64; inline;
{Gets the total system clock count}
{Note: This will normally come from the free running system timer in the board
 and is useful as a form of tick count but not for time keeping because
 the actual rate at which this increments is dependant on the system timer clock
 frequency of the specific board and may not be a measure of time in its raw form}
begin
 {} 
 if Assigned(ClockGetTotalHandler) then
  begin
   Result:=ClockGetTotalHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function ClockUpdateOffset:LongWord; inline;
{Update the system time offset between UTC and Local}
begin
 {}
 if Assigned(ClockUpdateOffsetHandler) then
  begin
   Result:=ClockUpdateOffsetHandler;
  end
 else
  begin
   Result:=ERROR_SUCCESS;
  end;
end;

{==============================================================================}

function ClockGetRate(ClockId:LongWord):LongWord; inline;
{Get the clock rate in Hz of the specified Clock}
begin
 {}
 if Assigned(ClockGetRateHandler) then
  begin
   Result:=ClockGetRateHandler(ClockId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function ClockSetRate(ClockId,Rate:LongWord;Turbo:Boolean):LongWord; inline;
{Set the clock rate in Hz of the specified Clock}
begin
 {}
 if Assigned(ClockSetRateHandler) then
  begin
   Result:=ClockSetRateHandler(ClockId,Rate,Turbo);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function ClockGetState(ClockId:LongWord):LongWord; inline;
{Get the state of the specified Clock}
begin
 {}
 if Assigned(ClockGetStateHandler) then
  begin
   Result:=ClockGetStateHandler(ClockId);
  end
 else
  begin
   Result:=CLOCK_STATE_OFF;
  end;
end;

{==============================================================================}

function ClockSetState(ClockId,State:LongWord):LongWord; inline;
{Set the state of the specified Clock}
begin
 {}
 if Assigned(ClockSetStateHandler) then
  begin
   Result:=ClockSetStateHandler(ClockId,State);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function ClockGetMinRate(ClockId:LongWord):LongWord; inline;
{Get the minimum clock rate in Hz of the specified Clock}
begin
 {}
 if Assigned(ClockGetMinRateHandler) then
  begin
   Result:=ClockGetMinRateHandler(ClockId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function ClockGetMaxRate(ClockId:LongWord):LongWord; inline;
{Get the maximum clock rate in Hz of the specified Clock}
begin
 {}
 if Assigned(ClockGetMaxRateHandler) then
  begin
   Result:=ClockGetMaxRateHandler(ClockId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}
{==============================================================================}
{Turbo Functions}
function TurboGetState(TurboId:LongWord):LongWord; inline;
{Get the Turbo state (0 equals Off / 1 equals On) of the specified device}
begin
 {}
 if Assigned(TurboGetStateHandler) then
  begin
   Result:=TurboGetStateHandler(TurboId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function TurboSetState(TurboId,State:LongWord):LongWord; inline;
{Set the Turbo state (0 equals Off / 1 equals On) of the specified device}
begin
 {}
 if Assigned(TurboSetStateHandler) then
  begin
   Result:=TurboSetStateHandler(TurboId,State);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
{==============================================================================}
{Voltage Functions}
function VoltageGetValue(VoltageId:LongWord):LongWord; inline;
{Get the current voltage level of the specified device}
begin
 {}
 if Assigned(VoltageGetValueHandler) then
  begin
   Result:=VoltageGetValueHandler(VoltageId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function VoltageSetValue(VoltageId,Value:LongWord):LongWord; inline;
{Set the current voltage level of the specified device}
begin
 {}
 if Assigned(VoltageSetValueHandler) then
  begin
   Result:=VoltageSetValueHandler(VoltageId,Value);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function VoltageGetMinValue(VoltageId:LongWord):LongWord; inline;
{Get the minimum voltage level of the specified device}
begin
 {}
 if Assigned(VoltageGetMinValueHandler) then
  begin
   Result:=VoltageGetMinValueHandler(VoltageId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function VoltageGetMaxValue(VoltageId:LongWord):LongWord; inline;
{Get the maximum voltage level of the specified device}
begin
 {}
 if Assigned(VoltageGetMaxValueHandler) then
  begin
   Result:=VoltageGetMaxValueHandler(VoltageId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}
{==============================================================================}
{Temperature Functions}
function TemperatureGetCurrent(TemperatureId:LongWord):LongWord; inline;
{Get the current temperature in thousandths of a degree C of the specified device}
begin
 {}
 if Assigned(TemperatureGetCurrentHandler) then
  begin
   Result:=TemperatureGetCurrentHandler(TemperatureId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function TemperatureGetMaximum(TemperatureId:LongWord):LongWord; inline;
{Get the maximum temperature in thousandths of a degree C of the specified device}
begin
 {}
 if Assigned(TemperatureGetMaximumHandler) then
  begin
   Result:=TemperatureGetMaximumHandler(TemperatureId);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}
{==============================================================================}
{GPU Memory Functions}
function GPUMemoryAllocate(Length,Alignment,Flags:LongWord):THandle; inline;
{Allocate memory from the GPU}
begin
 {}
 if Assigned(GPUMemoryAllocateHandler) then
  begin
   Result:=GPUMemoryAllocateHandler(Length,Alignment,Flags);
  end
 else
  begin
   Result:=INVALID_HANDLE_VALUE;
  end;
end;

{==============================================================================}

function GPUMemoryRelease(Handle:THandle):LongWord; inline;
{Release memory allocated from the GPU}
begin
 {}
 if Assigned(GPUMemoryReleaseHandler) then
  begin
   Result:=GPUMemoryReleaseHandler(Handle);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function GPUMemoryLock(Handle:THandle):LongWord; inline;
{Lock memory allocated from the GPU and return an address}
begin
 {}
 if Assigned(GPUMemoryLockHandler) then
  begin
   Result:=GPUMemoryLockHandler(Handle);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function GPUMemoryUnlock(Handle:THandle):LongWord; inline;
{Unlock memory allocated from the GPU}
begin
 {}
 if Assigned(GPUMemoryUnlockHandler) then
  begin
   Result:=GPUMemoryUnlockHandler(Handle);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
{==============================================================================}
{GPU Misc Functions}
function GPUExecuteCode(Address:Pointer;R0,R1,R2,R3,R4,R5:LongWord):LongWord; inline;
{Execute a block of code on the GPU}
begin
 {}
 if Assigned(GPUExecuteCodeHandler) then
  begin
   Result:=GPUExecuteCodeHandler(Address,R0,R1,R2,R3,R4,R5);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function DispmanxHandleGet(Resource:THandle):THandle; inline;
{Convert a Dispmanx Resouse handle to a Memory handle (Which can be passed to Lock/Unlock above)}
begin
 {}
 if Assigned(DispmanxHandleGetHandler) then
  begin
   Result:=DispmanxHandleGetHandler(Resource);
  end
 else
  begin
   Result:=INVALID_HANDLE_VALUE;
  end;
end;

{==============================================================================}

function EDIDBlockGet(Block:LongWord;Buffer:Pointer;Length:LongWord):LongWord; inline;
{Get an EDID block from HDMI}
begin
 {}
 if Assigned(EDIDBlockGetHandler) then
  begin
   Result:=EDIDBlockGetHandler(Block,Buffer,Length);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
{==============================================================================}
{Framebuffer Functions}
function FramebufferAvailable:Boolean; inline;
{Check if a framebuffer device is currently available}
begin
 {}
 if Assigned(FramebufferAvailableHandler) then
  begin
   Result:=FramebufferAvailableHandler;
  end
 else
  begin
   Result:=False;
  end;
end;

{==============================================================================}

function FramebufferAllocate(Alignment:LongWord;var Address,Length:LongWord):LongWord; inline;
{Allocate a new Framebuffer}
begin
 {}
 if Assigned(FramebufferAllocateHandler) then
  begin
   Result:=FramebufferAllocateHandler(Alignment,Address,Length);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferRelease:LongWord; inline;
{Release the current Framebuffer}
begin
 {}
 if Assigned(FramebufferReleaseHandler) then
  begin
   Result:=FramebufferReleaseHandler;
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferSetState(State:LongWord):LongWord; inline;
{Set the current Framebuffer (Display) state (0 for Off / 1 for On)}
begin
 {}
 if Assigned(FramebufferSetStateHandler) then
  begin
   Result:=FramebufferSetStateHandler(State);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferGetDimensions(var Width,Height,Top,Bottom,Left,Right:LongWord):LongWord; inline;
{Get the default Dimensions of the Framebuffer (Physical Width, Height and Overscan Top, Bottom, Left, Right in Pixels)}
begin
 {}
 if Assigned(FramebufferGetDimensionsHandler) then
  begin
   Result:=FramebufferGetDimensionsHandler(Width,Height,Top,Bottom,Left,Right);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferGetPhysical(var Width,Height:LongWord):LongWord; inline;
{Get the Physical Framebuffer Width and Height in Pixels}
{Note: The "physical" size is the size of the allocated buffer in memory,
       not the resolution of the video signal sent to the display device}
begin
 {}
 if Assigned(FramebufferGetPhysicalHandler) then
  begin
   Result:=FramebufferGetPhysicalHandler(Width,Height);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferSetPhysical(var Width,Height:LongWord):LongWord; inline;
{Set the Physical Framebuffer Width and Height in Pixels}
begin
 {}
 if Assigned(FramebufferSetPhysicalHandler) then
  begin
   Result:=FramebufferSetPhysicalHandler(Width,Height);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferTestPhysical(var Width,Height:LongWord):LongWord; inline;
{Test the Physical Framebuffer Width and Height in Pixels}
begin
 {}
 if Assigned(FramebufferTestPhysicalHandler) then
  begin
   Result:=FramebufferTestPhysicalHandler(Width,Height);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferGetVirtual(var Width,Height:LongWord):LongWord; inline;
{Get the Virtual Framebuffer Width and Height in Pixels}
{Note: The "virtual" size is the portion of buffer that is sent to the display device,
       not the resolution the buffer itself. This may be smaller than the allocated
       buffer size in order to implement panning}
begin
 {}
 if Assigned(FramebufferGetVirtualHandler) then
  begin
   Result:=FramebufferGetVirtualHandler(Width,Height);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;
       
{==============================================================================}
       
function FramebufferSetVirtual(var Width,Height:LongWord):LongWord; inline;
{Set the Virtual Framebuffer Width and Height in Pixels}
begin
 {}
 if Assigned(FramebufferSetVirtualHandler) then
  begin
   Result:=FramebufferSetVirtualHandler(Width,Height);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferTestVirtual(var Width,Height:LongWord):LongWord; inline;
{Test the Virtual Framebuffer Width and Height in Pixels}
begin
 {}
 if Assigned(FramebufferTestVirtualHandler) then
  begin
   Result:=FramebufferTestVirtualHandler(Width,Height);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
       
function FramebufferGetDepth(var Depth:LongWord):LongWord; inline;
{Get the Framebuffer Depth in Bits per Pixel}
begin
 {}
 if Assigned(FramebufferGetDepthHandler) then
  begin
   Result:=FramebufferGetDepthHandler(Depth);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferSetDepth(var Depth:LongWord):LongWord; inline;
{Set the Framebuffer Depth in Bits per Pixel}
begin
 {}
 if Assigned(FramebufferSetDepthHandler) then
  begin
   Result:=FramebufferSetDepthHandler(Depth);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferTestDepth(var Depth:LongWord):LongWord; inline;
{Test the Framebuffer Depth in Bits per Pixel}
begin
 {}
 if Assigned(FramebufferTestDepthHandler) then
  begin
   Result:=FramebufferTestDepthHandler(Depth);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferGetPixelOrder(var Order:LongWord):LongWord; inline;
{Get the Framebuffer Pixel Order (0 = BGR / 1 = RGB)}
begin
 {}
 if Assigned(FramebufferGetPixelOrderHandler) then
  begin
   Result:=FramebufferGetPixelOrderHandler(Order);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferSetPixelOrder(var Order:LongWord):LongWord; inline;
{Set the Framebuffer Pixel Order (0 = BGR / 1 = RGB)}
begin
 {}
 if Assigned(FramebufferSetPixelOrderHandler) then
  begin
   Result:=FramebufferSetPixelOrderHandler(Order);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferTestPixelOrder(var Order:LongWord):LongWord; inline;
{Test the Framebuffer Pixel Order (0 = BGR / 1 = RGB)}
begin
 {}
 if Assigned(FramebufferTestPixelOrderHandler) then
  begin
   Result:=FramebufferTestPixelOrderHandler(Order);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferGetAlphaMode(var Mode:LongWord):LongWord; inline;
{Get the Framebuffer Alpha Mode}
begin
 {}
 if Assigned(FramebufferGetAlphaModeHandler) then
  begin
   Result:=FramebufferGetAlphaModeHandler(Mode);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferSetAlphaMode(var Mode:LongWord):LongWord; inline;
{Set the Framebuffer Alpha Mode}
begin
 {}
 if Assigned(FramebufferSetAlphaModeHandler) then
  begin
   Result:=FramebufferSetAlphaModeHandler(Mode);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferTestAlphaMode(var Mode:LongWord):LongWord; inline;
{Test the Framebuffer Alpha Mode}
begin
 {}
 if Assigned(FramebufferTestAlphaModeHandler) then
  begin
   Result:=FramebufferTestAlphaModeHandler(Mode);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferGetPitch:LongWord; inline;
{Get the Framebuffer Pitch in Bytes per Line}
begin
 {}
 if Assigned(FramebufferGetPitchHandler) then
  begin
   Result:=FramebufferGetPitchHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function FramebufferGetOffset(var X,Y:LongWord):LongWord; inline;
{Get the Framebuffer Virtual Offset in Pixels}
begin
 {}
 if Assigned(FramebufferGetOffsetHandler) then
  begin
   Result:=FramebufferGetOffsetHandler(X,Y);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferSetOffset(var X,Y:LongWord):LongWord; inline;
{Set the Framebuffer Virtual Offset in Pixels}
begin
 {}
 if Assigned(FramebufferSetOffsetHandler) then
  begin
   Result:=FramebufferSetOffsetHandler(X,Y);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferTestOffset(var X,Y:LongWord):LongWord; inline;
{Test the Framebuffer Virtual Offset in Pixels}
begin
 {}
 if Assigned(FramebufferTestOffsetHandler) then
  begin
   Result:=FramebufferTestOffsetHandler(X,Y);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferGetOverscan(var Top,Bottom,Left,Right:LongWord):LongWord; inline;
{Get the Framebuffer Top, Bottom, Left and Right Overscan in Pixels}
begin
 {}
 if Assigned(FramebufferGetOverscanHandler) then
  begin
   Result:=FramebufferGetOverscanHandler(Top,Bottom,Left,Right);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferSetOverscan(var Top,Bottom,Left,Right:LongWord):LongWord; inline;
{Set the Framebuffer Top, Bottom, Left and Right Overscan in Pixels}
begin
 {}
 if Assigned(FramebufferSetOverscanHandler) then
  begin
   Result:=FramebufferSetOverscanHandler(Top,Bottom,Left,Right);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferTestOverscan(var Top,Bottom,Left,Right:LongWord):LongWord; inline;
{Test the Framebuffer Top, Bottom, Left and Right Overscan in Pixels}
begin
 {}
 if Assigned(FramebufferTestOverscanHandler) then
  begin
   Result:=FramebufferTestOverscanHandler(Top,Bottom,Left,Right);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferGetPalette(Buffer:Pointer;Length:LongWord):LongWord; inline;
{Get the Framebuffer Palette in RGBA values}
begin
 {}
 if Assigned(FramebufferGetPaletteHandler) then
  begin
   Result:=FramebufferGetPaletteHandler(Buffer,Length);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferSetPalette(Start,Count:LongWord;Buffer:Pointer;Length:LongWord):LongWord; inline;
{Set the Framebuffer Palette in RGBA values}
begin
 {}
 if Assigned(FramebufferSetPaletteHandler) then
  begin
   Result:=FramebufferSetPaletteHandler(Start,Count,Buffer,Length);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function FramebufferTestPalette(Start,Count:LongWord;Buffer:Pointer;Length:LongWord):LongWord; inline;
{Test the Framebuffer Palette in RGBA values}
begin
 {}
 if Assigned(FramebufferTestPaletteHandler) then
  begin
   Result:=FramebufferTestPaletteHandler(Start,Count,Buffer,Length);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;
       
{==============================================================================}
{Cursor Functions}
function CursorSetInfo(Width,Height,HotspotX,HotspotY:LongWord;Pixels:Pointer;Length:LongWord):LongWord; inline;
{Set the Cursor Info (Width and Height, Hotspot and Pixel image)}
begin
 {}
 if Assigned(CursorSetInfoHandler) then
  begin
   Result:=CursorSetInfoHandler(Width,Height,HotspotX,HotspotY,Pixels,Length);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function CursorSetState(Enabled:Boolean;X,Y:LongWord;Relative:Boolean):LongWord; inline;
{Set the Cursor State (Enabled, X and Y)}
{Relative: X, Y is relative to Display (Virtual) not Framebuffer (Physical)}
begin
 {}
 if Assigned(CursorSetStateHandler) then
  begin
   Result:=CursorSetStateHandler(Enabled,X,Y,Relative);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;
       
{==============================================================================}
{==============================================================================}
{DMA Functions}
function DMAAvailable:Boolean; inline;
{Check if DMA is currently available}
begin
 {}
 if Assigned(DMAAvailableHandler) then
  begin
   Result:=DMAAvailableHandler;
  end
 else
  begin
   Result:=False;
  end;
end;

{==============================================================================}

function DMAGetChannels:LongWord; inline;
{Get the currently enabled DMA channels}
begin
 {}
 if Assigned(DMAGetChannelsHandler) then
  begin
   Result:=DMAGetChannelsHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}
{==============================================================================}
{Handle Functions}
//To Do

{==============================================================================}
{==============================================================================}
{GPIO Functions}
function GPIORead(Reg:LongWord):LongWord; inline;
begin
 {}
 if Assigned(GPIOReadHandler) then
  begin
   Result:=GPIOReadHandler(Reg);
  end
 else 
  begin
   {Read Value}
   Result:=PLongWord(GPIO_REGS_BASE + Reg)^;
   
   {Memory Barrier}
   DataMemoryBarrier; {After the Last Read} 
  end; 
end;

{==============================================================================}

procedure GPIOWrite(Reg,Value:LongWord); inline;
begin
 {}
 if Assigned(GPIOWriteHandler) then
  begin
   GPIOWriteHandler(Reg,Value);
  end
 else
  begin
   {Memory Barrier}
   DataMemoryBarrier; {Before the First Write}
   
   {Write Value}
   PLongWord(GPIO_REGS_BASE + Reg)^:=Value;
  end; 
end;

{==============================================================================}

function GPIOInputGet(Pin:LongWord):LongWord; inline;
begin
 {}
 if Assigned(GPIOInputGetHandler) then
  begin
   Result:=GPIOInputGetHandler(Pin);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function GPIOInputWait(Pin,Timeout:LongWord):LongWord; inline;
begin
 {}
 if Assigned(GPIOInputWaitHandler) then
  begin
   Result:=GPIOInputWaitHandler(Pin,Timeout);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function GPIOInputEvent(Pin,Timeout:LongWord;Callback:TGPIOEvent;Data:Pointer):LongWord; inline;
begin
 {}
 if Assigned(GPIOInputEventHandler) then
  begin
   Result:=GPIOInputEventHandler(Pin,Timeout,Callback,Data);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}
 
function GPIOPullSelect(Pin,Mode:LongWord):LongWord; inline;
begin
 {}
 if Assigned(GPIOPullSelectHandler) then
  begin
   Result:=GPIOPullSelectHandler(Pin,Mode);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

procedure GPIOOutputSet(Reg,Value:LongWord); inline;
begin
 {}
 if Assigned(GPIOOutputSetHandler) then
  begin
   GPIOOutputSetHandler(Reg,Value);
  end
 else
  begin
   {Memory Barrier}
   DataMemoryBarrier; {Before the First Write}
   
   {Write Value}
   PLongWord(GPIO_REGS_BASE + Reg)^:=Value;
  end; 
end;

{==============================================================================}

procedure GPIOOutputClear(Reg,Value:LongWord); inline;
begin
 {}
 if Assigned(GPIOOutputClearHandler) then
  begin
   GPIOOutputClearHandler(Reg,Value);
  end
 else
  begin
   {Memory Barrier}
   DataMemoryBarrier; {Before the First Write}
   
   {Write Value}
   PLongWord(GPIO_REGS_BASE + Reg)^:=Value;
  end; 
end;

{==============================================================================}

procedure GPIOFunctionSelect(Reg,Value:LongWord); inline;
begin
 {}
 if Assigned(GPIOFunctionSelectHandler) then
  begin
   GPIOFunctionSelectHandler(Reg,Value);
  end
 else
  begin
   {Memory Barrier}
   DataMemoryBarrier; {Before the First Write}
   
   {Write Value}
   PLongWord(GPIO_REGS_BASE + Reg)^:=Value;
  end; 
end;

{==============================================================================}
{==============================================================================}
{RTC Functions}
function RTCAvailable:Boolean; inline;
{Check if a Real Time Clock (RTC) device is available}
begin
 {}
 if Assigned(RTCAvailableHandler) then
  begin
   Result:=RTCAvailableHandler;
  end
 else
  begin
   Result:=False;
  end;
end;

{==============================================================================}

function RTCGetTime:Int64; inline;
{Get the current time from a Real Time Clock device}
{Returned time is 100 nanosecond ticks since 1 January 1601}
{The same format as the ClockGetTime function}
begin
 {}
 if Assigned(RTCGetTimeHandler) then
  begin
   Result:=RTCGetTimeHandler;
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function RTCSetTime(const Time:Int64):LongWord; inline;
{Set the current time for a Real Time Clock device}
{Time: The time to be set}
{Return: The device time after setting}
{Time and returned time is 100 nanosecond ticks since 1 January 1601}
{The same format as the ClockSetTime function}
begin
 {}
 if Assigned(RTCSetTimeHandler) then
  begin
   Result:=RTCSetTimeHandler(Time);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}
{==============================================================================}
{Peripheral Functions}
function PeripheralGetBase:PtrUInt; inline;
{Get the base address of the peripherals}
begin
 {}
 if Assigned(PeripheralGetBaseHandler) then
  begin
   Result:=PeripheralGetBaseHandler;
  end
 else
  begin
   Result:=PERIPHERALS_BASE;
  end;
end;

{==============================================================================}

function PeripheralGetSize:LongWord; inline;
{Get the total size of the peripherals}
begin
 {}
 if Assigned(PeripheralGetSizeHandler) then
  begin
   Result:=PeripheralGetSizeHandler;
  end
 else
  begin
   Result:=PERIPHERALS_SIZE;
  end;
end;

{==============================================================================}

function PeripheralRead(Base,Reg:LongWord):LongWord; inline;
{Read from a Peripheral register}
begin
 {}
 if Assigned(PeripheralReadHandler) then
  begin
   Result:=PeripheralReadHandler(Base,Reg);
  end
 else
  begin 
   {Read Value}
   Result:=PLongWord(PERIPHERALS_BASE + Base + Reg)^;
   
   {Memory Barrier}
   DataMemoryBarrier; {After the Last Read} 
  end; 
end;
 
{==============================================================================}

procedure PeripheralWrite(Base,Reg,Value:LongWord); inline;
{Write to a Peripheral register}
begin
 {}
 if Assigned(PeripheralWriteHandler) then
  begin
   PeripheralWriteHandler(Base,Reg,Value);
  end
 else
  begin 
   {Memory Barrier}
   DataMemoryBarrier; {Before the First Write}
   
   {Write Value}
   PLongWord(PERIPHERALS_BASE + Base + Reg)^:=Value;
  end; 
end;

{==============================================================================}

function LocalPeripheralGetBase:PtrUInt; inline;
{Get the base address of the local peripherals (Peripherals local to each CPU)}
begin
 {}
 if Assigned(LocalPeripheralGetBaseHandler) then
  begin
   Result:=LocalPeripheralGetBaseHandler;
  end
 else
  begin
   Result:=LOCAL_PERIPHERALS_BASE;
  end;
end;

{==============================================================================}

function LocalPeripheralGetSize:LongWord; inline;
{Get the total size of the local peripherals (Peripherals local to each CPU)}
begin
 {}
 if Assigned(LocalPeripheralGetSizeHandler) then
  begin
   Result:=LocalPeripheralGetSizeHandler;
  end
 else
  begin
   Result:=LOCAL_PERIPHERALS_SIZE;
  end;
end;

{==============================================================================}
{==============================================================================}
{System Functions}
function GetSP:PtrUInt; inline;
{Get the current stack pointer (SP)}
begin
 {}
 if Assigned(GetSPHandler) then
  begin
   Result:=GetSPHandler;
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

function GetPC:PtrUInt; inline; 
{Get the current program counter (PC)}
begin
 {}
 if Assigned(GetPCHandler) then
  begin
   Result:=GetPCHandler;
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

function GetIRQ:Boolean; inline;
{Get Interrupts (IRQ) state}
{Return: True is enabled, False if disabled}
begin
 {}
 if Assigned(GetIRQHandler) then
  begin
   Result:=GetIRQHandler;
  end
 else
  begin
   Result:=True;
  end; 
end;

{==============================================================================}

procedure EnableIRQ; inline;
{Enable Interrupts (IRQ) unconditionally}
begin
 {}
 if Assigned(EnableIRQHandler) then
  begin
   EnableIRQHandler;
  end; 
end;

{==============================================================================}

procedure DisableIRQ; inline;
{Disable Interrupts (IRQ) unconditionally}
begin
 {}
 if Assigned(DisableIRQHandler) then
  begin
   DisableIRQHandler;
  end; 
end;

{==============================================================================}

function SaveIRQ:TIRQMask; inline;
{Disable Interrupts (IRQ) and return the previous state}
{Return: IRQ state when called}
begin
 {}
 if Assigned(SaveIRQHandler) then
  begin
   Result:=SaveIRQHandler;
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

function RestoreIRQ(IRQMask:TIRQMask):TIRQMask; inline;
{Restore Interrupts (IRQ) to a previous state}
{IRQMask: IRQ state to restore}
{Return: IRQ state when called}
begin
 {}
 if Assigned(RestoreIRQHandler) then
  begin
   Result:=RestoreIRQHandler(IRQMask);
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

function GetFIQ:Boolean; inline;
{Get Fast Interrupts (FIQ) state}
{Return: True is enabled, False if disabled}
begin
 {}
 if Assigned(GetFIQHandler) then
  begin
   Result:=GetFIQHandler;
  end
 else
  begin
   Result:=True;
  end; 
end;

{==============================================================================}

procedure EnableFIQ; inline;
{Enable Fast Interrupts (FIQ) unconditionally}
begin
 {}
 if Assigned(EnableFIQHandler) then
  begin
   EnableFIQHandler;
  end; 
end;

{==============================================================================}

procedure DisableFIQ; inline;
{Disable Fast Interrupts (FIQ) unconditionally}
begin
 {}
 if Assigned(DisableFIQHandler) then
  begin
   DisableFIQHandler;
  end; 
end;

{==============================================================================}

function SaveFIQ:TFIQMask; inline;
{Disable Fast Interrupts (FIQ) and return the previous state}
{Return: FIQ state when called}
begin
 {}
 if Assigned(SaveFIQHandler) then
  begin
   Result:=SaveFIQHandler;
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

function RestoreFIQ(FIQMask:TFIQMask):TFIQMask; inline;
{Restore Fast Interrupts (FIQ) to a previous state}
{FIQMask: FIQ state to restore}
{Return: FIQ state when called}
begin
 {}
 if Assigned(RestoreFIQHandler) then
  begin
   Result:=RestoreFIQHandler(FIQMask);
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

procedure EnableIRQFIQ; inline;
{Enable Interrupts and Fast Interrupts (IRQ/FIQ) unconditionally}
begin
 {}
 if Assigned(EnableIRQFIQHandler) then
  begin
   EnableIRQFIQHandler;
  end; 
end;

{==============================================================================}

procedure DisableIRQFIQ; inline;
{Disable Interrupts and Fast Interrupts (IRQ/FIQ) unconditionally}
begin
 {}
 if Assigned(DisableIRQFIQHandler) then
  begin
   DisableIRQFIQHandler;
  end; 
end;

{==============================================================================}

function SaveIRQFIQ:TIRQFIQMask; inline;
{Disable Interrupts and Fast Interrupts (IRQ/FIQ) and return the previous state}
{Return: IRQ/FIQ state when called}
begin
 {}
 if Assigned(SaveIRQFIQHandler) then
  begin
   Result:=SaveIRQFIQHandler;
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

function RestoreIRQFIQ(IRQFIQMask:TIRQFIQMask):TIRQFIQMask; inline;
{Restore Interrupts and Fast Interrupts (IRQ/FIQ) to a previous state}
{IRQFIQMask: IRQ/FIQ state to restore}
{Return: IRQ/FIQ state when called}
begin
 {}
 if Assigned(RestoreIRQFIQHandler) then
  begin
   Result:=RestoreIRQFIQHandler(IRQFIQMask);
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

function GetAbort:Boolean; inline;
{Get Abort state}
{Return: True is enabled, False if disabled}
begin
 {}
 if Assigned(GetAbortHandler) then
  begin
   Result:=GetAbortHandler;
  end
 else
  begin
   Result:=True;
  end; 
end;

{==============================================================================}

procedure EnableAbort; inline;
{Enable Abort unconditionally}
begin
 {}
 if Assigned(EnableAbortHandler) then
  begin
   EnableAbortHandler;
  end; 
end;

{==============================================================================}

procedure DisableAbort; inline;
{Disable Abort unconditionally}
begin
 {}
 if Assigned(DisableAbortHandler) then
  begin
   DisableAbortHandler;
  end; 
end;

{==============================================================================}

function SaveAbort:TAbortMask; inline;
{Disable Abort and return the previous state}
{Return: Abort state when called}
begin
 {}
 if Assigned(SaveAbortHandler) then
  begin
   Result:=SaveAbortHandler;
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

function RestoreAbort(AbortMask:TAbortMask):TAbortMask; inline;
{Restore Abort to a previous state}
{AbortMask: Abort state to restore}
{Return: Abort state when called}
begin
 {}
 if Assigned(RestoreAbortHandler) then
  begin
   Result:=RestoreAbortHandler(AbortMask);
  end
 else
  begin
   Result:=0;
  end; 
end;

{==============================================================================}

procedure Halt; inline;
{Halt the current processor}
begin
 {}
 if Assigned(HaltHandler) then
  begin
   HaltHandler;
  end; 
end;

{==============================================================================}

procedure Pause; inline;
{Pause the current processor and wait for an Event or Interrupt (Where Applicable)}
begin
 {}
 if Assigned(PauseHandler) then
  begin 
   PauseHandler;
  end; 
end;

{==============================================================================}

function HaltThread(ExitCode:LongWord):LongWord; inline; 
{Halt the current thread}
begin
 {}
 if Assigned(HaltThreadHandler) then
  begin
   Result:=HaltThreadHandler(ExitCode);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

procedure SendEvent; inline;
{Send a signal that an Event has occurred (Where Applicable)}
begin
 {}
 if Assigned(SendEventHandler) then
  begin
   SendEventHandler;
  end; 
end;

{==============================================================================}

procedure WaitForEvent; inline;
{Wait for an Event to occur (Where Applicable)}
begin
 {}
 if Assigned(WaitForEventHandler) then
  begin
   WaitForEventHandler;
  end; 
end;

{==============================================================================}

procedure WaitForInterrupt; inline;
{Wait for an Interrupt to occur (Where Applicable)}
begin
 {}
 if Assigned(WaitForInterruptHandler) then
  begin
   WaitForInterruptHandler;
  end; 
end;
  
{==============================================================================}
  
procedure ReadMemoryBarrier; inline;
{Perform a Read Memory Barrier operation (Where Applicable)}
begin
 {}
 if Assigned(ReadMemoryBarrierHandler) then
  begin
   ReadMemoryBarrierHandler;
  end; 
end;

{==============================================================================}

procedure WriteMemoryBarrier; inline;
{Perform a Write Memory Barrier operation (Where Applicable)}
begin
 {}
 if Assigned(WriteMemoryBarrierHandler) then
  begin
   WriteMemoryBarrierHandler;
  end; 
end;

{==============================================================================}

procedure DataMemoryBarrier; inline;
{Perform a Data Memory Barrier operation (Where Applicable)}
begin
 {}
 if Assigned(DataMemoryBarrierHandler) then
  begin
   DataMemoryBarrierHandler;
  end; 
end;

{==============================================================================}

procedure DataSynchronizationBarrier; inline;
{Perform a Data Synchronization Barrier operation (Where Applicable)}
begin
 {}
 if Assigned(DataSynchronizationBarrierHandler) then
  begin
   DataSynchronizationBarrierHandler;
  end; 
end;

{==============================================================================}

procedure InstructionMemoryBarrier; inline;
{Perform an Instruction Memory Barrier operation (Where Applicable)}
begin
 {}
 if Assigned(InstructionMemoryBarrierHandler) then
  begin
   InstructionMemoryBarrierHandler;
  end; 
end;

{==============================================================================}

procedure InvalidateTLB; inline;
{Perform an Invalidate Entire TLB operation (Where Applicable)}
begin
 {}
 if Assigned(InvalidateTLBHandler) then
  begin
   InvalidateTLBHandler;
  end; 
end;

{==============================================================================}

procedure InvalidateDataTLB; inline;
{Perform an Invalidate Data TLB operation (Where Applicable)}
begin
 {}
 if Assigned(InvalidateDataTLBHandler) then
  begin
   InvalidateDataTLBHandler;
  end; 
end;

{==============================================================================}

procedure InvalidateInstructionTLB; inline;
{Perform an Invalidate Instruction TLB operation (Where Applicable)}
begin
 {}
 if Assigned(InvalidateInstructionTLBHandler) then
  begin
   InvalidateInstructionTLBHandler;
  end; 
end;

{==============================================================================}

procedure InvalidateCache; inline;
{Perform an Invalidate Entire Cache operation (Where Applicable)}
begin
 {}
 if Assigned(InvalidateCacheHandler) then
  begin
   InvalidateCacheHandler;
  end; 
end;

{==============================================================================}

procedure CleanDataCache; inline;
{Perform a Clean Data Cache operation (Where Applicable)}
begin
 {}
 if Assigned(CleanDataCacheHandler) then
  begin
   CleanDataCacheHandler;
  end; 
end;

{==============================================================================}

procedure InvalidateDataCache; inline;
{Perform an Invalidate Data Cache operation (Where Applicable)}
begin
 {}
 if Assigned(InvalidateDataCacheHandler) then
  begin
   InvalidateDataCacheHandler;
  end; 
end;

{==============================================================================}

procedure CleanAndInvalidateDataCache; inline;
{Perform a Clean and Invalidate Data Cache operation (Where Applicable)}
begin
 {}
 if Assigned(CleanAndInvalidateDataCacheHandler) then
  begin
   CleanAndInvalidateDataCacheHandler;
  end; 
end;
  
{==============================================================================}

procedure InvalidateInstructionCache; inline;
{Perform an Invalidate Instruction Cache operation (Where Applicable)}
begin
 {}
 if Assigned(InvalidateInstructionCacheHandler) then
  begin
   InvalidateInstructionCacheHandler;
  end; 
end;

{==============================================================================}

procedure CleanDataCacheRange(Address,Size:LongWord); inline;
{Perform a Clean Data Cache Range operation (Where Applicable)}
begin
 {}
 if Assigned(CleanDataCacheRangeHandler) then
  begin
   CleanDataCacheRangeHandler(Address,Size);
  end; 
end;

{==============================================================================}

procedure InvalidateDataCacheRange(Address,Size:LongWord); inline;
{Perform an Invalidate Data Cache Range operation (Where Applicable)}
begin
 {}
 if Assigned(InvalidateDataCacheRangeHandler) then
  begin
   InvalidateDataCacheRangeHandler(Address,Size);
  end; 
end;

{==============================================================================}

procedure CleanAndInvalidateDataCacheRange(Address,Size:LongWord); inline;
{Perform a Clean and Invalidate Data Cache Range operation (Where Applicable)}
begin
 {}
 if Assigned(CleanAndInvalidateDataCacheRangeHandler) then
  begin
   CleanAndInvalidateDataCacheRangeHandler(Address,Size);
  end; 
end;

{==============================================================================}

procedure InvalidateInstructionCacheRange(Address,Size:LongWord); inline;
{Perform an Invalidate Instruction Cache Range operation (Where Applicable)}
begin
 {}
 if Assigned(InvalidateInstructionCacheRangeHandler) then
  begin
   InvalidateInstructionCacheRangeHandler(Address,Size);
  end; 
end;

{==============================================================================}

procedure FlushPrefetchBuffer; inline;
{Perform a Flush Prefetch Buffer operation (Where Applicable)}
begin
 {}
 if Assigned(FlushPrefetchBufferHandler) then
  begin
   FlushPrefetchBufferHandler;
  end; 
end;

{==============================================================================}

procedure FlushBranchTargetCache; inline;
{Perform a Flush Entire Branch Target Cache operation (Where Applicable)}
begin
 {}
 if Assigned(FlushBranchTargetCacheHandler) then
  begin
   FlushBranchTargetCacheHandler;
  end; 
end;

{==============================================================================}

procedure ContextSwitch(OldStack,NewStack:Pointer;NewThread:TThreadHandle); inline;
{Perform a Context Switch from one thread to another}
begin
 {}
 if Assigned(ContextSwitchHandler) then
  begin
   ContextSwitchHandler(OldStack,NewStack,NewThread);
  end;
end;

{==============================================================================}

procedure ContextSwitchIRQ(OldStack,NewStack:Pointer;NewThread:TThreadHandle); inline;
{Perform a Context Switch from one thread to another from an IRQ handler}
begin
 {}
 if Assigned(ContextSwitchIRQHandler) then
  begin
   ContextSwitchIRQHandler(OldStack,NewStack,NewThread);
  end;
end;

{==============================================================================}

procedure ContextSwitchFIQ(OldStack,NewStack:Pointer;NewThread:TThreadHandle); inline;
{Perform a Context Switch from one thread to another from an FIQ handler}
begin
 {}
 if Assigned(ContextSwitchFIQHandler) then
  begin
   ContextSwitchFIQHandler(OldStack,NewStack,NewThread);
  end;
end;

{==============================================================================}

procedure ContextSwitchSWI(OldStack,NewStack:Pointer;NewThread:TThreadHandle); inline;
{Perform a Context Switch from one thread to another from a software interrupt handler}
begin
 {}
 if Assigned(ContextSwitchSWIHandler) then
  begin
   ContextSwitchSWIHandler(OldStack,NewStack,NewThread);
  end;
end;

{==============================================================================}

function InterlockedOr(var Target:LongInt;Value:LongInt):LongInt; inline;
{Perform an atomic OR operation}
begin
 {}
 if Assigned(InterlockedOrHandler) then
  begin
   Result:=InterlockedOrHandler(Target,Value);
  end
 else
  begin
   Result:=Target;
  end;
end;

{==============================================================================}

function InterlockedXor(var Target:LongInt;Value:LongInt):LongInt; inline;
{Perform an atomic XOR operation}
begin
 {}
 if Assigned(InterlockedXorHandler) then
  begin
   Result:=InterlockedXorHandler(Target,Value);
  end
 else
  begin
   Result:=Target;
  end;
end;

{==============================================================================}

function InterlockedAnd(var Target:LongInt;Value:LongInt):LongInt; inline;
{Perform an atomic AND operation}
begin
 {}
 if Assigned(InterlockedAndHandler) then
  begin
   Result:=InterlockedAndHandler(Target,Value);
  end
 else
  begin
   Result:=Target;
  end;
end;

{==============================================================================}

function InterlockedDecrement(var Target:LongInt):LongInt; inline;
{Perform an atomic decrement operation}
begin
 {}
 if Assigned(InterlockedDecrementHandler) then
  begin
   Result:=InterlockedDecrementHandler(Target);
  end
 else
  begin
   Result:=Target;
  end;
end;

{==============================================================================}

function InterlockedIncrement(var Target:LongInt):LongInt; inline;
{Perform an atomic increment operation}
begin
 {}
 if Assigned(InterlockedIncrementHandler) then
  begin
   Result:=InterlockedIncrementHandler(Target);
  end
 else
  begin
   Result:=Target;
  end;
end;

{==============================================================================}

function InterlockedExchange(var Target:LongInt;Source:LongInt):LongInt; inline;
{Perform an atomic exchange operation}
begin
 {}
 if Assigned(InterlockedExchangeHandler) then
  begin
   Result:=InterlockedExchangeHandler(Target,Source);
  end
 else
  begin
   Result:=Target;
  end;
end;

{==============================================================================}

function InterlockedAddExchange(var Target:LongInt;Source:LongInt):LongInt; inline;
{Perform an atomic add and exchange operation}
begin
 {}
 if Assigned(InterlockedAddExchangeHandler) then
  begin
   Result:=InterlockedAddExchangeHandler(Target,Source);
  end
 else
  begin
   Result:=Target;
  end;
end;

{==============================================================================}

function InterlockedCompareExchange(var Target:LongInt;Source,Compare:LongInt):LongInt; inline;
{Perform an atomic compare and exchange operation}
begin
 {}
 if Assigned(InterlockedCompareExchangeHandler) then
  begin
   Result:=InterlockedCompareExchangeHandler(Target,Source,Compare);
  end
 else
  begin
   Result:=Target;
  end;
end;

{==============================================================================}

function PageTableGetBase:PtrUInt; inline;
{Get the base address of the first level page table}
begin
 {}
 if Assigned(PageTableGetBaseHandler) then
  begin
   Result:=PageTableGetBaseHandler;
  end
 else
  begin
   Result:=PAGE_TABLE_BASE;
  end;
end;

{==============================================================================}

function PageTableGetSize:LongWord; inline;
{Get the size of the first level page table}
begin
 {}
 if Assigned(PageTableGetSizeHandler) then
  begin
   Result:=PageTableGetSizeHandler;
  end
 else
  begin
   Result:=PAGE_TABLE_SIZE;
  end;
end;

{==============================================================================}

function PageTableGetEntry(Address:PtrUInt):TPageTableEntry; inline;
{Get the Page Table entry that corresponds to the supplied virtual address}
begin
 {}
 if Assigned(PageTableGetEntryHandler) then
  begin
   Result:=PageTableGetEntryHandler(Address);
  end
 else
  begin
   FillChar(Result,SizeOf(TPageTableEntry),0);
  end;
end;

{==============================================================================}

function PageTableSetEntry(Address:PtrUInt;const PageTableEntry:TPageTableEntry):LongWord; inline;
{Set the Page Table entry that corresponds to the supplied virtual address}
begin
 {}
 if Assigned(PageTableSetEntryHandler) then
  begin
   Result:=PageTableSetEntryHandler(Address,PageTableEntry);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}

function PageTablesGetAddress:PtrUInt; inline;
{Get the address of the second level page tables}
begin
 {}
 if Assigned(PageTablesGetAddressHandler) then
  begin
   Result:=PageTablesGetAddressHandler;
  end
 else
  begin
   Result:=PAGE_TABLES_ADDRESS;
  end;
end;

{==============================================================================}

function PageTablesGetLength:LongWord; inline;
{Get the size of the second level page tables}
begin
 {}
 if Assigned(PageTablesGetLengthHandler) then
  begin
   Result:=PageTablesGetLengthHandler;
  end
 else
  begin
   Result:=PAGE_TABLES_LENGTH;
  end;
end;

{==============================================================================}

function PageTablesGetCount:LongWord; inline;
{Get the number of second level page tables}
begin
 {}
 if Assigned(PageTablesGetCountHandler) then
  begin
   Result:=PageTablesGetCountHandler;
  end
 else
  begin
   Result:=PAGE_TABLES_COUNT;
  end;
end;

{==============================================================================}

function PageTablesGetShift:LongWord; inline;
{Get the multiplier to convert count to actual size of the second level page tables}
begin
 {}
 if Assigned(PageTablesGetShiftHandler) then
  begin
   Result:=PageTablesGetShiftHandler;
  end
 else
  begin
   Result:=PAGE_TABLES_SHIFT;
  end;
end;

{==============================================================================}

function VectorTableGetBase:PtrUInt; inline;
{Get the base address of the interrupt vector table}
begin
 {}
 if Assigned(VectorTableGetBaseHandler) then
  begin
   Result:=VectorTableGetBaseHandler;
  end
 else
  begin
   Result:=VECTOR_TABLE_BASE;
  end;
end;

{==============================================================================}

function VectorTableGetSize:LongWord; inline;
{Get the size of the interrupt vector table}
begin
 {}
 if Assigned(VectorTableGetSizeHandler) then
  begin
   Result:=VectorTableGetSizeHandler;
  end
 else
  begin
   Result:=VECTOR_TABLE_SIZE;
  end;
end;

{==============================================================================}

function VectorTableGetEntry(Number:LongWord):PtrUInt; inline;
{Get the interrupt vector table entry that corresponds to the supplied number}
begin
 {}
 if Assigned(VectorTableGetEntryHandler) then
  begin
   Result:=VectorTableGetEntryHandler(Number);
  end
 else
  begin
   Result:=0;
  end;
end;

{==============================================================================}

function VectorTableSetEntry(Number:LongWord;Address:PtrUInt):LongWord; inline;
{Set the interrupt vector table entry that corresponds to the supplied number}
begin
 {}
 if Assigned(VectorTableSetEntryHandler) then
  begin
   Result:=VectorTableSetEntryHandler(Number,Address);
  end
 else
  begin
   Result:=ERROR_CALL_NOT_IMPLEMENTED;
  end;
end;

{==============================================================================}
{==============================================================================}
{Exception Functions}
procedure HardwareException(AType:LongWord;Address,Frame:Pointer);
var
 E:Exception;
begin
 {}
 {$IFDEF EXCEPTION_DEBUG}
 Inc(HardwareExceptionCounter);
 HardwareExceptionAddress:=LongWord(Address);
 {$ENDIF}
 
 E:=nil;
 
 {Check Type}
 case AType of
  EXCEPTION_TYPE_DATA_ABORT:E:=DataAbortException;
  EXCEPTION_TYPE_PREFETCH_ABORT:E:=PrefetchAbortException;
  EXCEPTION_TYPE_UNDEFINED_INSTRUCTION:E:=UndefinedInstructionException;
 end;
 
 {Raise Exception}
 Raise E at Address,Frame;
end;

{==============================================================================}

procedure UnhandledException(Obj:TObject;Addr:CodePointer;FrameCount:LongInt;Frames:PCodePointer); {[public,alias:'FPC_BREAK_UNHANDLED_EXCEPTION'];}
begin
 {}
 {$IFDEF EXCEPTION_DEBUG}
 Inc(UnhandledExceptionCounter);
 {$ENDIF}
 
 {Log Exception}
 if PLATFORM_LOG_ENABLED then
  begin
   {Log Address}
   PlatformLogError('An unhandled exception occurred at 0x' + HexStr(Addr));
   
   {Check Object}
   if Obj <> nil then
    begin
     {Check Class}
     if Obj is Exception then
      begin
       PlatformLogError(' Exception ' + Obj.ClassName + ': ' + Exception(Obj).Message);
      end
     else if Obj is TObject then
      begin 
       PlatformLogError(' Exception object ' + Obj.ClassName + ' is not of class Exception');
      end
     else
      begin
       PlatformLogError(' Exception object is not a valid class');
      end;
    end; 

   {Log Thread}
   PlatformLogError(' Halting thread ID 0x' + HexStr(GetCurrentThreadID,8));    
  end;  
 
 {Halt Thread}
 HaltThread(ERROR_EXCEPTION);
 
 {Never Executed}
 while True do
  begin
   Sleep(0);
  end;
end;

{==============================================================================}
{==============================================================================}
{Text IO Functions}
procedure TextIOOpen(var F:Text;AWrite:TTextIOWriteChar;ARead:TTextIOReadChar;AMode:LongInt;AUserData:Pointer);
var
 TextIOData:PTextIOData;
begin
 {}
 Assign(F,'');
 
 TextIOData:=@TextRec(F).UserData[1];
 if TextIOData = nil then Exit;
 
 TextRec(F).Mode:=AMode;
 case AMode of
  fmInput:TextRec(F).Handle:=StdInputHandle;
  fmOutput:TextRec(F).Handle:=StdOutputHandle;
 end;
 
 TextRec(F).CloseFunc:=@TextIOClose;
 TextRec(F).FlushFunc:=nil;
 case AMode of
  fmInput:begin
    TextRec(F).InOutFunc:=@TextIORead;
   end; 
  fmOutput:begin
    TextRec(F).InOutFunc:=@TextIOWrite;
    TextRec(F).FlushFunc:=@TextIOWrite;
   end;
 end;
 
 TextIOData^.WriteChar:=AWrite;
 TextIOData^.ReadChar:=ARead;
 TextIOData^.UserData:=AUserData;
end;

{==============================================================================}

procedure TextIOClose(var T:TextRec);
begin
 {}
 {Nothing}
end;

{==============================================================================}
 
procedure TextIORead(var T:TextRec);
var
 TextIOData:PTextIOData;
begin
 {}
 TextIOData:=@T.UserData[1];
 if TextIOData = nil then Exit;
 
 InOutRes:=0;
 T.BufEnd:=TextIOReadData(TextIOData^.ReadChar,TextIOData^.UserData,PChar(T.BufPtr),T.BufSize);
 T.BufPos:=0;
end;

{==============================================================================}

procedure TextIOWrite(var T:TextRec);
var
 Next:PChar;
 Count:LongInt;
 TextIOData:PTextIOData;
begin
 {}
 if T.BufPos = 0 then Exit;
 
 TextIOData:=@T.UserData[1];
 if TextIOData = nil then Exit;
 
 Count:=0;
 Next:=PChar(T.BufPtr);
 while Count < T.BufPos do
  begin
   if not TextIOData^.WriteChar(Next^,TextIOData^.UserData) then Break;
   
   Inc(Next);
   Inc(Count);
  end;
   
 if Count <> T.BufPos then InOutRes:=101 else InOutRes:=0;
   
 T.BufPos:=0;
end;

{==============================================================================}
 
function TextIOReadData(ARead:TTextIOReadChar;AUserData:Pointer;ABuffer:PChar;ACount:LongInt):LongInt;
var
 Ch:Char;
 EndChar:Boolean;
begin
 {}
 Result:=0;
 
 EndChar:=False;
 while (Result < ACount) and not(EndChar) do
  begin
   if ARead(Ch,AUserData) then
    begin
     if Ch = #10 then EndChar:=True;
     
     ABuffer^:=Ch;
     
     Inc(ABuffer);
     Inc(Result);
    end;
  end;
end;

{==============================================================================}
{==============================================================================}
{Console Functions}
function ConsoleWriteChar(ACh:Char;AUserData:Pointer):Boolean; inline;
begin
 {}
 if Assigned(ConsoleWriteCharHandler) then
  begin
   Result:=ConsoleWriteCharHandler(ACh,AUserData);
  end
 else
  begin
   Result:=True; {Default True}
  end;  
end;

{==============================================================================}

function ConsoleReadChar(var ACh:Char;AUserData:Pointer):Boolean; inline;
begin
 {}
 if Assigned(ConsoleReadCharHandler) then
  begin
   Result:=ConsoleReadCharHandler(ACh,AUserData);
  end
 else
  begin
   ACh:=#0;
   
   Result:=True; {Default True}
  end;  
end;  

{==============================================================================}

function ConsoleHideMouse(AUserData:Pointer):Boolean; inline;
begin
 {}
 if Assigned(ConsoleHideMouseHandler) then
  begin
   Result:=ConsoleHideMouseHandler(AUserData);
  end
 else
  begin
   Result:=True; {Default True}
  end;  
end;

{==============================================================================}

function ConsoleShowMouse(X,Y:LongWord;AUserData:Pointer):Boolean; inline;
begin
 {}
 if Assigned(ConsoleShowMouseHandler) then
  begin
   Result:=ConsoleShowMouseHandler(X,Y,AUserData);
  end
 else
  begin
   Result:=True; {Default True}
  end;  
end;

{==============================================================================}

function ConsoleReadMouse(var X,Y,Buttons:LongWord;AUserData:Pointer):Boolean; inline;
 begin
 {}
 if Assigned(ConsoleReadMouseHandler) then
  begin
   Result:=ConsoleReadMouseHandler(X,Y,Buttons,AUserData);
  end
 else
  begin
   X:=0;
   Y:=0;
   Buttons:=0;
   
   Result:=True; {Default True}
  end;  
end;

{==============================================================================}
{==============================================================================}
{Name Functions}
function HostGetName:String; inline;
begin
 {}
 if Assigned(HostGetNameHandler) then
  begin
   Result:=HostGetNameHandler;
  end
 else
  begin
   Result:=HOST_NAME; 
  end;  
end;

{==============================================================================}

function HostSetName(const AName:String):Boolean; inline;
begin
 {}
 if Assigned(HostSetNameHandler) then
  begin
   Result:=HostSetNameHandler(AName);
  end
 else
  begin
   Result:=False;
   
   if Length(AName) = 0 then Exit;
   
   HOST_NAME:=AName;
   
   Result:=True;
  end;  
end;

{==============================================================================}

function HostGetDomain:String; inline;
begin
 {}
 if Assigned(HostGetDomainHandler) then
  begin
   Result:=HostGetDomainHandler;
  end
 else
  begin
   Result:=HOST_DOMAIN; 
  end;  
end;

{==============================================================================}

function HostSetDomain(const ADomain:String):Boolean; inline;
begin
 {}
 if Assigned(HostSetDomainHandler) then
  begin
   Result:=HostSetDomainHandler(ADomain);
  end
 else
  begin
   Result:=False;
   
   if Length(ADomain) = 0 then Exit;
   
   HOST_DOMAIN:=ADomain;
   
   Result:=True;
  end;  
end;

{==============================================================================}
{==============================================================================}
{Logging Functions}
procedure LoggingOutput(const AText:String); inline;
begin
 {}
 if Assigned(LoggingOutputHandler) then
  begin
   LoggingOutputHandler(AText);
  end;
end;
 
{==============================================================================}
 
procedure LoggingOutputEx(AFacility,ASeverity:LongWord;const ATag,AContent:String); inline;
begin
 {}
 if Assigned(LoggingOutputExHandler) then
  begin
   LoggingOutputExHandler(AFacility,ASeverity,ATag,AContent);
  end;
end;
 
{==============================================================================}
{==============================================================================}
{Utility Functions}
function FirstBitSet(Value:LongWord):LongWord; inline;
{Find the first set bit in a nonzero 32 bit value}
{Returns 31 for MSB and 0 for LSB (0xFFFFFFFF / -1 if no bits are set)}
begin
 {}
 if Assigned(FirstBitSetHandler) then
  begin
   Result:=FirstBitSetHandler(Value);
  end
 else
  begin
   Result:=31 - CountLeadingZeros(Value);
  end;  
end;

{==============================================================================}

function CountLeadingZeros(Value:LongWord):LongWord; inline;
{Count the number of leading 0 bits in a nonzero 32 bit value}
{Returns 32 if no bits are set}
begin
 {}
 if Assigned(CountLeadingZerosHandler) then
  begin
   Result:=CountLeadingZerosHandler(Value);
  end
 else
  begin
   Result:=32;
  end;  
end;

{==============================================================================}

function PhysicalToIOAddress(Address:Pointer):LongWord; inline;
{Convert Physical address to an IO addresses (Where Applicable)}
begin
 {}
 Result:=(LongWord(Address) - IO_BASE) + IO_ALIAS;
end;

{==============================================================================}

function IOAddressToPhysical(Address:Pointer):LongWord; inline;
{Convert an IO address to a Physical address (Where Applicable)}
begin
 {}
 Result:=(LongWord(Address) - IO_ALIAS) + IO_BASE;
end;

{==============================================================================}

function PhysicalToBusAddress(Address:Pointer):LongWord; inline;
{Convert a Physical address to a Bus address (Where Applicable)}
begin
 {}
 Result:=LongWord(Address) or BUS_ALIAS;
end;

{==============================================================================}

function BusAddressToPhysical(Address:Pointer):LongWord; inline;
{Convert a Bus address to a Physical address (Where Applicable)}
begin
 {}
 Result:=LongWord(Address) and not(BUS_ALIAS);
end;

{==============================================================================}

procedure NanosecondDelay(Nanoseconds:LongWord);
{Non sleep wait for a number of nanoseconds}
{Nanoseconds: Number of nanoseconds to wait}
var
 Start:Int64;
 Target:Int64;
 Delay:LongWord;
begin
 {}
 {Calculate Delay (Number of clock ticks to wait)}
 Delay:=CLOCK_CYCLES_PER_NANOSECOND * Nanoseconds; 
 
 {Get Starting Clock Count}
 Start:=ClockGetTotal;
 
 {Get Ending Clock Count}
 Target:=Start + Delay;
 
 {Check Count}
 if Target > Start then
  begin
   while ClockGetTotal < Target do
    begin
     {Nothing}
    end;
  end;
end;

{==============================================================================}

procedure MicrosecondDelay(Microseconds:LongWord);
{Non sleep wait for a number of microseconds}
{Microseconds: Number of microseconds to wait}
var
 Start:Int64;
 Target:Int64;
 Delay:LongWord;
begin
 {}
 {Calculate Delay (Number of clock ticks to wait)}
 Delay:=CLOCK_CYCLES_PER_MICROSECOND * Microseconds; 
 
 {Get Starting Clock Count}
 Start:=ClockGetTotal;
 
 {Get Ending Clock Count}
 Target:=Start + Delay;
 
 {Check Count}
 if Target > Start then
  begin
   while ClockGetTotal < Target do
    begin
     {Nothing}
    end;
  end;
end;

{==============================================================================}

procedure MillisecondDelay(Milliseconds:LongWord);
{Non sleep wait for a number of milliseconds}
{Milliseconds: Number of milliseconds to wait}
var
 Start:Int64;
 Target:Int64;
 Delay:LongWord;
begin
 {}
 {Calculate Delay (Number of clock ticks to wait)}
 Delay:=CLOCK_CYCLES_PER_MILLISECOND * Milliseconds; 
 
 {Get Starting Clock Count}
 Start:=ClockGetTotal;
 
 {Get Ending Clock Count}
 Target:=Start + Delay;
 
 {Check Count}
 if Target > Start then
  begin
   while ClockGetTotal < Target do
    begin
     {Nothing}
    end;
  end;
end;

{==============================================================================}

procedure NanosecondDelayEx(Nanoseconds:LongWord;Wait:Boolean);
{Non sleep wait for a number of nanoseconds}
{Nanoseconds: Number of nanoseconds to wait}
{Wait: Use WaitForInterrupt on each loop to reduce power consumption}
{Note: Not suitable for use by interrupt handlers if wait is true}
var
 Start:Int64;
 Target:Int64;
 Delay:LongWord;
begin
 {}
 {Calculate Delay (Number of clock ticks to wait)}
 Delay:=CLOCK_CYCLES_PER_NANOSECOND * Nanoseconds; 
 
 {Get Starting Clock Count}
 Start:=ClockGetTotal;
 
 {Get Ending Clock Count}
 Target:=Start + Delay;
 
 {Check Count}
 if Target > Start then
  begin
   while ClockGetTotal < Target do
    begin
     if Wait then
      begin
       WaitForInterrupt;
      end;
    end;
  end;
end;

{==============================================================================}

procedure MicrosecondDelayEx(Microseconds:LongWord;Wait:Boolean);
{Non sleep wait for a number of microseconds}
{Microseconds: Number of microseconds to wait}
{Wait: Use WaitForInterrupt on each loop to reduce power consumption}
{Note: Not suitable for use by interrupt handlers if wait is true}
var
 Start:Int64;
 Target:Int64;
 Delay:LongWord;
begin
 {}
 {Calculate Delay (Number of clock ticks to wait)}
 Delay:=CLOCK_CYCLES_PER_MICROSECOND * Microseconds; 
 
 {Get Starting Clock Count}
 Start:=ClockGetTotal;
 
 {Get Ending Clock Count}
 Target:=Start + Delay;
 
 {Check Count}
 if Target > Start then
  begin
   while ClockGetTotal < Target do 
    begin
     if Wait then
      begin
       WaitForInterrupt;
      end;
    end;
  end;
end;

{==============================================================================}

procedure MillisecondDelayEx(Milliseconds:LongWord;Wait:Boolean);
{Non sleep wait for a number of milliseconds}
{Milliseconds: Number of milliseconds to wait}
{Wait: Use WaitForInterrupt on each loop to reduce power consumption}
{Note: Not suitable for use by interrupt handlers if wait is true}
var
 Start:Int64;
 Target:Int64;
 Delay:LongWord;
begin
 {}
 {Calculate Delay (Number of clock ticks to wait)}
 Delay:=CLOCK_CYCLES_PER_MILLISECOND * Milliseconds; 
 
 {Get Starting Clock Count}
 Start:=ClockGetTotal;
 
 {Get Ending Clock Count}
 Target:=Start + Delay;
 
 {Check Count}
 if Target > Start then
  begin
   while ClockGetTotal < Target do 
    begin
     if Wait then
      begin
       WaitForInterrupt;
      end;
    end;
  end;
end;

{==============================================================================}
{==============================================================================}
{RTL Functions}
function SysGetTickCount:DWORD;
begin
 {}
 if CLOCK_CYCLES_PER_MILLISECOND > 0 then
  begin
   Result:=ClockGetCount div CLOCK_CYCLES_PER_MILLISECOND;
  end
 else
  begin
   Result:=ClockGetCount;
  end;  
end;

{==============================================================================}

function SysGetTickCount64:ULONGLONG;
begin
 {}
 if CLOCK_CYCLES_PER_MILLISECOND > 0 then
  begin
   Result:=ClockGetTotal div CLOCK_CYCLES_PER_MILLISECOND;
  end
 else
  begin
   Result:=ClockGetTotal;
  end;  
end;

{==============================================================================}

procedure SysGetLocalTime(var SystemTime:TSystemTime);
{Get the current local time as a SystemTime value}
{Note: Includes timezone offset if configured}
var
 Offset:Int64;
 ClockTime:Int64;
 LocalTime:Int64;
 DateTime:TDateTime;
begin
 {}
 FillChar(SystemTime,SizeOf(TSystemTime),0);
 
 {Get Clock Time}
 ClockTime:=ClockGetTime;
 
 {Check Clock Time}
 if ClockTime < TIME_TICKS_TO_1899 then Exit;
 
 {Check for Update}
 if ClockTime >= (TIMEZONE_UPDATE_LAST + TIME_TICKS_PER_MINUTE) then
  begin
   {Update Clock Offset}
   if ClockUpdateOffset = ERROR_SUCCESS then
    begin
     TIMEZONE_UPDATE_LAST:=ClockTime;
    end;
  end;
  
 {Get Timezone Offset}
 Offset:=TIMEZONE_TIME_OFFSET; {Avoid 32 bit overflow}
 Offset:=Offset * TIME_TICKS_PER_MINUTE;
 
 {Convert to Local Time}
 LocalTime:=ClockTime - (Offset);

 {Check Local Time} 
 if LocalTime < TIME_TICKS_TO_1899 then Exit;
 
 {Convert to DateTime}
 DateTime:=((LocalTime - TIME_TICKS_TO_1899) div TIME_TICKS_PER_DAY) + (((LocalTime - TIME_TICKS_TO_1899) mod TIME_TICKS_PER_DAY) / TIME_TICKS_PER_DAY);

 {Convert to SystemTime}
 DecodeDate(DateTime,SystemTime.Year,SystemTime.Month,SystemTime.Day);
 DecodeTime(DateTime,SystemTime.Hour,SystemTime.Minute,SystemTime.Second,SystemTime.MilliSecond);
end;

{==============================================================================}

function SysGetLocalTimeOffset:Integer;
{Get the current local time offset value}
begin
 {}
 Result:=TIMEZONE_TIME_OFFSET;
end;

{==============================================================================}
{==============================================================================}
{Platform Helper Functions}
procedure PlatformLog(Level:LongWord;const AText:String);
var
 WorkBuffer:String;
begin
 {}
 {Check Level}
 if Level < PLATFORM_DEFAULT_LOG_LEVEL then Exit;
 
 WorkBuffer:='';
 {Check Level}
 if Level = PLATFORM_LOG_LEVEL_DEBUG then
  begin
   WorkBuffer:=WorkBuffer + '[DEBUG] ';
  end
 else if Level = PLATFORM_LOG_LEVEL_ERROR then
  begin
   WorkBuffer:=WorkBuffer + '[ERROR] ';
  end;
 
 {Add Prefix}
 WorkBuffer:=WorkBuffer + 'Platform: ';
 
 {Output Logging} 
 LoggingOutputEx(LOGGING_FACILITY_PLATFORM,LogLevelToLoggingSeverity(Level),'Platform',WorkBuffer + AText);
end;

{==============================================================================}

procedure PlatformLogInfo(const AText:String);
begin
 {}
 PlatformLog(PLATFORM_LOG_LEVEL_INFO,AText);
end;

{==============================================================================}

procedure PlatformLogError(const AText:String);
begin
 {}
 PlatformLog(PLATFORM_LOG_LEVEL_ERROR,AText);
end;

{==============================================================================}

procedure PlatformLogDebug(const AText:String);
begin
 {}
 PlatformLog(PLATFORM_LOG_LEVEL_DEBUG,AText);
end;

{==============================================================================}
{==============================================================================}

initialization 
 {Nothing}
 
{==============================================================================}
 
finalization
 {Nothing}
 
{==============================================================================}
{==============================================================================}

end.