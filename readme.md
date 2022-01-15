## Описание
Патчер игровых файлов Borderlands GOTY Enhanced с целью уменьшения шрифта названия в карточках оружия, так как некоторые названия вместе с префиксами могут занимать больше двух строк.

Для работы необходима предварительная распаковка с помощью decompress.exe с сайта [Gildor.org](http://www.gildor.org/downloads).

## Ключи запуска
`-nolog` отключение журналирования в файл umapPatchLog.txt

`-rollback` откат изменений графического интерфейса. Откат производится только в части интерфейса, обратного сжатия файлов не произойдет. Для возврата к исходному состоянию файла необходима проверка кэша Steam или переустановка игры.

## Изменения в GFX-файлах

### .umap файлы

__интерфейс торговых автоматов__
menus_vending vending_machine


- синие
```
sprite  532 object  451 scalex 52428->40000
                        scaley 65536->50000

                    451 xmax 5804 -> 7580
                        ymin -40 -> 100
                        ymax 870 -> 1010

sprite  590 object  581 scalex 52428->40000
                        scaley 65536->50000

                    581 xmax 5804 -> 7580
                        ymin -40 -> 100
                        ymax 870 -> 1010						
```						
- красные
```
sprite  654 object  654 scalex 52428->40000
                        scaley 65536->50000
                        
                    654 xmax 6414 -> 8190
                        ymin -40 -> 100
                        ymax 955 -> 1100						
```
- зеленые
```
sprite  860 object  847 scalex 52428->40000
                        scaley 65536->50000

                    847 xmax 6414 -> 8190
                        ymin -40 -> 100
                        ymax 969 -> 1100

sprite  885 object  876 scalex 52428->40000
                        scaley 65536->50000

                    876 xmax 6414 -> 8190
                        ymin -40 -> 100
                        ymax 969 -> 1100						
```
- серые
```
sprite  1085 object 1067 scalex 52428->40000
                         scaley 65536->50000

                    1067 xmax 6414 -> 8190
                         ymin -40 -> 100
                         ymax 930 -> 1100
						
sprite  1110 object 1101 scalex 52428->40000
                         scaley 65536->50000

                    1101 xmax 6414 -> 8190
                         ymin -40 -> 100
                         ymax 960 -> 1100
```						 

### Startup_RUS.upk

__карточки оружия в сундуках и на земле__
inworld_ui weapon_card

```
sprite  190 object  109 scalex 52428->40000
                        scaley 65536->50000

                    109 xmax 5804 -> 7580
                        ymin -40 -> 100
                        ymax 870 -> 1010
```

__награда за задание__
menus_mission mission_interface
```
sprite  424 object  341 scalex 52428->40000
                        scaley 65536->50000

                    341 xmax 6221 -> 8000
                        ymin -40 -> 100
                        ymax 870 -> 1010
```

### WillowGame.upk

__инвентарь игрока__
menus_ingame_redux status_menu
```
sprite  825 object  790 scalex 52428->40000
                        scaley 65536->50000

                    790 xmax 6221 -> 8000
                        ymin -40 -> 100
                        ymax 870 -> 1010

sprite  854 object  844 scalex 52428->40000
                        scaley 65536->50000

                    844 xmax 5804 -> 7580
                        ymin -40 -> 100
                        ymax 870 -> 1085
						
sprite  923 object  581 scalex 52428->40000
                        scaley 65536->50000

                    581 xmax 6414 -> 8190
                        ymin -40 -> 100
                        ymax 945 -> 1085						
```

### DLC2\Maps\dlc2_lobby_p.umap

__банк__
menus_bank bank
```
sprite  539 object  411 scalex 62259->50000
                        scaley 62259->50000

                    411 xmax 4554 -> 6340
                        ymin -40 -> 100
                        ymax 945 -> 1060

sprite  568 object  558 scalex 52428->40000
                        scaley 65536->50000

                    558 xmax 5804 -> 7690
                        ymin -40 -> 100
                        ymax 870 -> 1025
						
sprite  617 object  608 scalex 52428->40000
                        scaley 65536->50000

                    608 xmax 6221 -> 8000
                        ymin -40 -> 100
                        ymax 870 -> 1025						
```

### Дополнительно найденные карточки
Карточки, найденные в интерфейсе, но эффект от их изменения не обнаружен.

__weaponcard__ в interface\inworld_ui.upk
```
sprite  184 object  99  scalex 52428->10000
```
__menus_ingame_redux status_menu__ в interface\inworld_ui.upk
```
sprite  515 object  470 scalex 52428->40000
                    514 scalex 52428->40000

sprite  590 object  581 scalex 52428->40000
                    589 scalex 52428->40000

sprite  597 object  514 scalex 52428->40000
```

__menus_ingame_redux status_menu__ в WillowGame.upk
```
sprite  515 object  470 scalex 52428->40000
                    514 scalex 52428->40000

sprite  590 object  581 scalex 52428->40000
                    589 scalex 52428->40000

sprite    597    object    514    scalex    52428->40000
```
