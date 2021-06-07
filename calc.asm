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
szMsg byte "�ο�ʼ�ĵط�",0ah,0
wintitle byte "�� �� �� ���� 1120180678",0
imgpath byte "./calc.jpg",0
tmpv_ byte "x=%d,y=%d",10,0
ftoa_format byte "%.0lf",0
img_main ACL_Image <>
num_bgcolor ACL_Color 00F2F2F2H ;����ͬϵͳ��colorref�����ֽڷֱ������,B,G,R
tmpstr0 byte "%d",10
num byte "0",0
op_now dd 0;��������1����+��2����-��3����*��4����/��5����sin��6����cos��7����tan
num1 real8 0.0
num2 real8 0.0
uistr db 20 DUP(0)
currdigit db 0;��ǰ�м�λ��
fp_flag db 0;�Ƿ�������С����������
currfloat dd 0;��ǰ�м�λС��
currfloatF real8 1.0

.code


showOP proc x:sbyte;ascii
	invoke beginPaint
	invoke setTextSize,60
	invoke setTextBkColor,num_bgcolor
	mov AL,x
	mov uistr[0],al
	mov uistr[1],0;�ַ�������
	invoke putImage,offset img_main,0,0;�ػ�
	invoke paintText,20,110,addr uistr;��ʾ��
	invoke endPaint
	ret
showOP endp

showDigit proc x:real8
	invoke beginPaint
	invoke setTextSize,60
	invoke setTextBkColor,num_bgcolor
	invoke mylftoa,x,offset uistr,offset ftoa_format
	;invoke myitoa,x,offset uistr
	invoke putImage,offset img_main,0,0;�ػ�
	invoke paintText,20,110,addr uistr
	invoke endPaint
	ret
showDigit endp

pushNum proc;����Ϊ01ʱ���ã��Ѳ�����ѹջ
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

appendDigit proc x:dword;����һλ����
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
;��һ����������Ļص�������x��y�ֱ����ť�����ꡣ���¶�Ӧ��������ʱӦ��ִ�еĴ��롣
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
	mov op_now,0;������
	ret

inputCB endp

mouseCB proc x:dword,y:dword,button:dword,event:dword
;��������¼�
	cmp button,LEFT_BUTTON
	jne gogogo
	cmp event,BUTTON_UP
	jne gogogo
	;��������¼�
	mov eax,y
	sub eax,195
	jl gogogo ;�����Ϸ��հ����ĵ��
	sub edx,edx;�����λ
	mov eax,x
	mov ebx,157
	div ebx;x/157���жϴ�С����������һ��
	sub ecx,ecx
	mov ecx,eax
	mov eax,y
	sub edx,edx;�����λ
	mov ebx,67
	div ebx
	sub eax,3;��Ϊ����հ������ò���������y��Ҫ��ȥ3���ƫ�ơ�
	;���ڣ��кŴ���ecx��кŴ���eax��.
	pushad
	;invoke printf,addr tmpv_,ecx,eax
	popad
	invoke inputCB,ecx,eax
	ret 0 ;����ֱ�ӷ��ص�0ƫ�Ƶ�λ�ã��������ƫ�����޶���+16��byte���Ͳ�����
gogogo:
	mov eax,0
	ret 0;����Ϊʲô��������Ҳ��֪��
mouseCB endp

draw0 proc
	invoke beginPaint
	invoke setTextBkColor,0H
	;invoke paintText,470,463,addr num;157,195;67
	invoke endPaint
	ret
draw0 endp


main proc
	invoke init_first ;�ȵ����������ʼ������
	invoke initWindow, offset wintitle,330,200,625,535 ;Ȼ���ʼ�����ڣ���һ��
	;invoke myitoa,12345,offset uistr
	;invoke printf,offset uistr
	invoke loadImage,offset imgpath,offset img_main
	invoke registerMouseEvent,mouseCB
	invoke beginPaint;Ȼ��ʼ����
	invoke putImage,offset img_main,0,0
	invoke setTextSize,60
	invoke setTextBkColor,num_bgcolor
	invoke paintText,20,110,addr num
	invoke endPaint;�������������Գ������ɴ�beginpaint��endpaint
	invoke draw0
	invoke init_second ;�����¼�ѭ��
;	invoke MessageBoxA, 0,offset szMsg,offset szMsg,0
	mov eax,0
	ret
main endp
end main

