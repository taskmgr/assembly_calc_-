;
.386
.model flat,stdcall
option casemap:none

INCLUDELIB msvcrt.lib
INCLUDELIB acllib.lib
includelib mylib.lib
include acllib.inc


;printf	PROTO C:ptr sbyte, :VARARG
myitoa proto C:dword,:ptr sbyte
mylftoa proto C:real8,:ptr sbyte,:ptr sbyte

.const
r8_10 real8 10.0
r8_0p1 real8 0.1
r8_zero real8 0.0
r8_one real8 1.0

.data
szMsg byte "梦开始的地方",0ah,0
wintitle byte "计 算 器 —— 1120180678",0
imgpath byte "./calc.jpg",0
tmpv_ byte "x=%d,y=%d",10,0
ftoa_format byte "%.0lf",0
img_main ACL_Image <>
num_bgcolor ACL_Color 00F2F2F2H ;定义同系统的colorref，四字节分别代表：空,B,G,R
tmpstr0 byte "%d",10
num byte "0",0
op_now dd 0;操作符，1代表+，2代表-，3代表*，4代表/，5代表sin，6代表cos，7代表tan
num1 real8 0.0
num2 real8 0.0
uistr db 20 DUP(0)
currdigit db 0;当前有几位数
fp_flag db 0;是否在输入小数点后的数字
currfloat dd 0;当前有几位小数
currfloatF real8 1.0

.code


showOP proc x:sbyte;ascii
	invoke beginPaint
	invoke setTextSize,60
	invoke setTextBkColor,num_bgcolor
	mov AL,x
	mov uistr[0],al
	mov uistr[1],0;字符串结束
	invoke putImage,offset img_main,0,0;重绘
	invoke paintText,20,110,addr uistr;显示字
	invoke endPaint
	ret
showOP endp

showDigit proc x:real8
	invoke beginPaint
	invoke setTextSize,60
	invoke setTextBkColor,num_bgcolor
	invoke mylftoa,x,offset uistr,offset ftoa_format
	;invoke myitoa,x,offset uistr
	invoke putImage,offset img_main,0,0;重绘
	invoke paintText,20,110,addr uistr
	invoke endPaint
	ret
showDigit endp

pushNum proc;符号为01时调用，把操作数压栈
	fld num2
	fstp num1
	fld [r8_zero]
	fstp num2
pushNum endp

calcNum proc
	;mov currfloat,0
	mov fp_flag,0
	fld1
	fstp currfloatF
	cmp op_now,0
	je end_calcNum
	fld num1
	cmp op_now,1
	je plus_calcNum
	cmp op_now,2
	je minus_calcNum
	cmp op_now,3
	je multi_calcNum
	cmp op_now,4
	je divide_calcNum
	cmp op_now,5
	je sin_calcNum
	cmp op_now,6
	je cos_calcNum
	cmp op_now,7
	je tan_calcNum
plus_calcNum:
	fld num2
	faddp
	jmp show_calcNum

minus_calcNum:
	fld num2
	fsubp
	jmp show_calcNum

multi_calcNum:
	fld num2
	fmulp
	jmp show_calcNum

divide_calcNum:
	fld num2
	fdivp
	jmp show_calcNum

sin_calcNum:
	fsin
	jmp show_calcNum
	
cos_calcNum:
	fcos
	jmp show_calcNum

tan_calcNum:
	fptan
	jmp show_calcNum

show_calcNum:
	fstp num1
	fld [r8_zero]
	fstp num2
	invoke showDigit,num1
	ret
end_calcNum:
	ret
calcNum endp

appendDigit proc x:dword;附加一位数字
	cmp fp_flag,0
	jne float_append
	fld num2
	fld [r8_10] ; mov eax,10
	fmulp;mul num2
	fild x ;mov num2,eax ;mov eax,x
	faddp	;add num2,eax
	fstp num2
	invoke showDigit,num2
	ret
	float_append:
	add currfloat,1
	fld currfloatF
	fld r8_10
	fdivp
	FST currfloatF
	fild x ;mov num2,eax ;mov eax,x
	fmulp;mul num2
	fld num2
	faddp	;add num2,eax
	fstp num2
	mov eax,currfloat
	ADD eax,'0'
	mov ftoa_format[2],al
	invoke showDigit,num2
	ret

appendDigit endp

inputCB proc x:dword,y:dword
;这一部分是输入的回调函数，x和y分别代表按钮的坐标。往下对应按键按下时应该执行的代码。
	cmp x,0
	je L_x0
	cmp x,1
	je L_x1
	cmp x,2
	je L_x2
	cmp x,3
	je L_x3

	L_x0:
	cmp y,0
	je L_x0y0
	cmp y,1
	je L_x0y1
	cmp y,2
	je L_x0y2	
	cmp y,3
	je L_x0y3
	cmp y,4
	je L_x0y4

	L_x1:
	cmp y,0
	je L_x1y0
	cmp y,1
	je L_x1y1
	cmp y,2
	je L_x1y2	
	cmp y,3
	je L_x1y3
	cmp y,4
	je L_x1y4

	L_x2:
	cmp y,0
	je L_x2y0
	cmp y,1
	je L_x2y1
	cmp y,2
	je L_x2y2	
	cmp y,3
	je L_x2y3
	cmp y,4
	je L_x2y4

	L_x3:
	cmp y,0
	je L_x3y0
	cmp y,1
	je L_x3y1
	cmp y,2
	je L_x3y2	
	cmp y,3
	je L_x3y3
	cmp y,4
	je L_x3y4

	L_x0y0:
	
	invoke showOP,'T'
	cmp op_now,0
	jne L_x0y0_cmpne
	invoke pushNum
	mov op_now,7
	ret
	L_x0y0_cmpne:
	invoke calcNum
	mov op_now,7
	ret

	L_x0y1:
	invoke appendDigit,7
	ret

	L_x0y2:
	invoke appendDigit,4
	ret

	L_x0y3:
	invoke appendDigit,1
	ret

	L_x0y4:
	mov op_now,0
	fldz
	fst num1
	fstp num2
	mov fp_flag,0
	mov currfloat,0
	fld1
	fstp currfloatF
	invoke showDigit,num1
	ret

	L_x1y0:
	invoke showOP,'C'
	cmp op_now,0
	jne L_x1y0_cmpne
	invoke pushNum
	mov op_now,6
	ret
	L_x1y0_cmpne:
	invoke calcNum
	mov op_now,6
	

	L_x1y1:
	invoke appendDigit,8
	ret

	L_x1y2:
	invoke appendDigit,5
	ret

	L_x1y3:
	invoke appendDigit,2
	ret

	L_x1y4:
	invoke appendDigit,0
	ret

	L_x2y0:
	invoke showOP,'S'
	cmp op_now,0
	jne L_x2y0_cmpne
	invoke pushNum
	mov op_now,5
	ret
	L_x2y0_cmpne:
	invoke calcNum
	mov op_now,5
	ret

	L_x2y1:
	invoke appendDigit,9
	ret

	L_x2y2:
	invoke appendDigit,6
	ret

	L_x2y3:
	invoke appendDigit,3
	ret

	L_x2y4:
	mov fp_flag,1
	ret

	L_x3y0:
	invoke showOP,'/'
	cmp op_now,0
	jne L_x3y0_cmpne
	invoke pushNum
	mov op_now,4
	ret
	L_x3y0_cmpne:
	invoke calcNum
	mov op_now,4
	ret

	L_x3y1:
	invoke showOP,'*'
	cmp op_now,0
	jne L_x3y1_cmpne
	invoke pushNum
	mov op_now,3
	ret
	L_x3y1_cmpne:
	invoke calcNum
	mov op_now,3
	ret

	L_x3y2:
	invoke showOP,'-'
	cmp op_now,0
	jne L_x3y2_cmpne
	invoke pushNum
	mov op_now,2
	ret
	L_x3y2_cmpne:
	invoke calcNum
	mov op_now,2
	ret

	L_x3y3:
	invoke showOP,'+'
	cmp op_now,0
	jne L_x3y3_cmpne
	invoke pushNum
	mov op_now,1
	ret
	L_x3y3_cmpne:
	invoke calcNum
	mov op_now,1
	ret

	L_x3y4:
	mov ftoa_format[2],'6'
	invoke calcNum
	mov op_now,0;算符清空
	ret

inputCB endp

mouseCB proc x:dword,y:dword,button:dword,event:dword
;鼠标点击的事件
	cmp button,LEFT_BUTTON
	jne gogogo
	cmp event,BUTTON_UP
	jne gogogo
	;左键单击事件
	mov eax,y
	sub eax,195
	jl gogogo ;过滤上方空白区的点击
	sub edx,edx;清零高位
	mov eax,x
	mov ebx,157
	div ebx;x/157；判断大小来看属于哪一列
	sub ecx,ecx
	mov ecx,eax
	mov eax,y
	sub edx,edx;清零高位
	mov ebx,67
	div ebx
	sub eax,3;因为上面空白像素用不到，所以y需要减去3格的偏移。
	;现在：行号存在ecx里，列号存在eax里.
	pushad
	;invoke printf,addr tmpv_,ecx,eax
	popad
	invoke inputCB,ecx,eax
	ret 0 ;必须直接返回到0偏移的位置，如果不加偏移量限定会+16个byte，就不对了
gogogo:
	mov eax,0
	ret 0;至于为什么会这样我也不知道
mouseCB endp

draw0 proc
	invoke beginPaint
	invoke setTextBkColor,0H
	;invoke paintText,470,463,addr num;157,195;67
	invoke endPaint
	ret
draw0 endp


main proc
	invoke init_first ;先调用这个，初始化环境
	invoke initWindow, offset wintitle,330,200,625,535 ;然后初始化窗口，就一次
	;invoke myitoa,12345,offset uistr
	;invoke printf,offset uistr
	invoke loadImage,offset imgpath,offset img_main
	invoke registerMouseEvent,mouseCB
	invoke beginPaint;然后开始画画
	invoke putImage,offset img_main,0,0
	invoke setTextSize,60
	invoke setTextBkColor,num_bgcolor
	invoke paintText,20,110,addr num
	invoke endPaint;结束画画；可以出现若干次beginpaint、endpaint
	invoke draw0
	invoke init_second ;启动事件循环
;	invoke MessageBoxA, 0,offset szMsg,offset szMsg,0
	mov eax,0
	ret
main endp
end main

