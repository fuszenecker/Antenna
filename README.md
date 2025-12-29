# Antenna

## Dipólantenna – Árameloszlás és Kisugárzott Energia

*(GitHub Markdown + MathJax kompatibilis verzió)*

A vékony, félhullámú dipól árameloszlása jó közelítéssel koszinuszos:

$$
I(z) = I_0 \cos\left(\frac{\pi z}{L}\right), \qquad |z| \le \frac{L}{2}
$$

A lokális kisugárzott teljesítmény arányos az áram négyzetével:

$$
P(z) \propto I(z)^2 = I_0^2 \cos^2\left(\frac{\pi z}{L}\right)
$$

A továbbiakban a teljesítményt **normalizáljuk**, így a középen 1, a végeken 0 lesz.

### A kisugárzott energia a dipól mentén

A középponttól számított relatív távolság legyen:

$$
s = \frac{z}{L/2}, \qquad 0 \le s \le 1
$$

A kisugárzott energia a \(-z \ldots +z\) szakaszra integrálva:

$$
F(s) = 
\frac{
\displaystyle \int_{-z}^{+z} \cos^2\left(\frac{\pi u}{L}\right)\,du
}{
\displaystyle \int_{-L/2}^{+L/2} \cos^2\left(\frac{\pi u}{L}\right)\,du
}
$$

Az integrál zárt alakban:

$$
F(s) = s + \frac{1}{\pi}\sin(\pi s)
$$

Ez adja meg, hogy a dipól teljes kisugárzott energiájának hány százaléka keletkezik a középtől számított \(s\) relatív távolságig.

### Összes kisugárzott energia táblázat (5% lépésköz)

| Távolság a középtől | Kisugárzott energia |
|---------------------|----------------------|
| 0%                  | 0.0%                |
| 5%                  | 10.0%               |
| 10%                 | 19.8%               |
| 15%                 | 29.5%               |
| 20%                 | 38.8%               |
| 25%                 | 47.5%               |
| 30%                 | 55.8%               |
| 35%                 | 63.4%               |
| 40%                 | 70.3%               |
| 45%                 | 76.5%               |
| 50%                 | 81.8%               |
| 55%                 | 86.5%               |
| 60%                 | 90.3%               |
| 65%                 | 93.4%               |
| 70%                 | 95.8%               |
| 75%                 | 97.5%               |
| 80%                 | 98.8%               |
| 85%                 | 99.5%               |
| 90%                 | 99.8%               |
| 95%                 | 100.0%              |
| 100%                | 100.0%              |

### Megjegyzések

- A teljes kisugárzott energia **~82%-a** a dipól **középső 50%** hosszában keletkezik.  
- A végek közeli szakaszok (90–100%) gyakorlatilag **elhanyagolható** hozzájárulást adnak.  
- Ez jól mutatja, miért kritikus a dipól középső részének környezete (magasság, vezetők közelsége stb.).

