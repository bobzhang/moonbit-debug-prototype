 expecting format:
 修改prettyprint实现来使打印结果符合以下规则：
 1. in flatten mode: no spaces around e in [e], spaces around `"k":v` in { "k":v }, spaces around `field: e` in { field: e }
 2. in multiline mode: need trailing comma 
 3. 修改 inspect test， 如果和这里的规则不同
 4. 增加足够的多行模式测试/嵌套多行测试

 例子：
 [a, b, c]
 [
   a,
   b,
   c,
 ]

 { field: value, field: value }
 {
   field: value,
   field: value,
 }

 { "k": v, "k": v }
 {
   "k": v,
   "k": v,
 }

 Enum(a, b, c)
 Enum(
   a,
   b,
   c,
 )
