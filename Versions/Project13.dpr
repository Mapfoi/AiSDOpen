program ProjectVersion;

uses
  SysUtils,
  Math;

const
  WIDTH = 15;
  HEIGHT = 15;

type
  TFloor = array [1 .. HEIGHT, 1 .. WIDTH] of Char;

  TPoint = record
    x, y: Integer;
  end;

var

  povt : Integer;
  Floor3: TFloor = (
    '###############',
    '#     #      S#',
    '#     #    #  #',
    '#     #    #  #',
    '##   ####  ####',
    '#             #',
    '#      #      #',
    '############# #',
    '#             #',
    '#  ## #### ## #',
    '#  #   #    # #',
    '#  #   #    # #',
    '## ## #### ## #',
    '#S            #',
    '###############'
  );

  Floor2: TFloor = (
    '###############',
    '#E      #    C#',
    '#####   #     #',
    '#       #     #',
    '#  ###### #####',
    '#             #',
    '#     #       #',
    '############  #',
    '#      #      #',
    '#  #   #####  #',
    '#  #   #####  #',
    '#  #   #####  #',
    '#  #   #####  #',
    '#C #         E#',
    '###############'
  );

  Floor1: TFloor = (
    '###############',
    '#J  #        P#',
    '#   #         #',
    '#  ##  ########',
    '#  #   ########',
    '#  #   ########',
    '#      ########',
    '#   ###########',
    '#             #',
    '########      #',
    '#      ###### #',
    '#             #',
    '#      #      #',
    '#J     #     J#',
    '###############'
  );

  Visited: array [1 .. HEIGHT, 1 .. WIDTH] of Boolean;
  Path: array [1 .. HEIGHT, 1 .. WIDTH] of Boolean;
  CurrentFloor: Integer;

{ Глобальные массивы направлений (вверх, вниз, влево, вправо) }
var
  dx: array [1 .. 4] of Integer = (-1, 1, 0, 0);
  dy: array [1 .. 4] of Integer = (0, 0, -1, 1);

{ Вывод предыстории и легенды карты }
procedure PrintIntro;
begin
  Writeln('Вас похитили пришельцы!');
  Writeln('Мы определили ваше местоположение. Ниже приведена карта, на которой показан маршрут до выхода.');
  Writeln;
  Writeln('Легенда карты:');
  Writeln('  # - стена');
  Writeln('  (пробел) - свободное пространство');
  Writeln('  S - лестницы на 3 этаже (выход с 3-го этажа)');
  Writeln('  E - лифты на 2 этаже (выход с 2-го этажа)');
  Writeln('  P - выход с 1 этажа');
  Writeln('  J - точка появления на 1 этаже');
  Writeln('  X - ваше текущее местоположение');
  Writeln;
  Writeln('Следуйте карте, чтобы спастись!');
  Writeln('Нажмите Enter для начала...');
  Readln;
end;

{ Сбрасывает массивы для отметок посещённых клеток и маршрута }
procedure ResetArrays;
var
  i, j: Integer;
begin
  for i := 1 to HEIGHT do
    for j := 1 to WIDTH do
    begin
      Visited[i, j] := False;
      Path[i, j] := False;
    end;
end;

{ Вывод маршрута.
  Если клетка является стартовой, выводится "X".
  Если клетка входит в найденный путь, выводится специальный символ,
  за исключением случая, когда эта клетка уже содержит целевой символ. }
procedure PrintPath(var floor: TFloor; startX, startY: Integer; target: Char);
var
  i, j: Integer;
begin
  for i := 1 to HEIGHT do
  begin
    for j := 1 to WIDTH do
    begin
      if (i = startX) and (j = startY) then
        Write('X ')
      else if (floor[i, j] = target) then
        Write(floor[i, j], ' ')
      else if Path[i, j] then
        Write(Char($04), ' ')
      else
        Write(floor[i, j], ' ');
    end;
    Writeln;
  end;
end;

{ Реализация BFS для поиска кратчайшего пути.
  Если путь до символа target найден, функция восстанавливает его,
  отмечая клетки маршрута в массиве Path. }
function BFSPath(var floor: TFloor; startX, startY: Integer; target: Char): Boolean;
var
  queue: array of TPoint;
  head, tail, i, nx, ny: Integer;
  current, neighbor, targetPoint: TPoint;
  found: Boolean;
  Parent: array [1 .. HEIGHT, 1 .. WIDTH] of TPoint;
begin
  ResetArrays;
  { Инициализируем массив }
  for i := 1 to HEIGHT do
    FillChar(Parent[i], SizeOf(Parent[i]), 0);

  SetLength(queue, HEIGHT * WIDTH);
  head := 0;
  tail := 0;

  current.x := startX;
  current.y := startY;
  queue[tail] := current;
  Inc(tail);
  Visited[startX, startY] := True;
  Parent[startX, startY] := current;

  found := False;

  while head < tail do
  begin
    current := queue[head];
    Inc(head);
    if floor[current.x, current.y] = target then
    begin
      found := True;
      targetPoint := current;
      Break;
    end;
    for i := 1 to 4 do
    begin
      nx := current.x + dx[i];
      ny := current.y + dy[i];
      if (nx >= 1) and (nx <= HEIGHT) and (ny >= 1) and (ny <= WIDTH) then
        if (floor[nx, ny] <> '#') and (not Visited[nx, ny]) then
        begin
          Visited[nx, ny] := True;
          neighbor.x := nx;
          neighbor.y := ny;
          Parent[nx, ny] := current;
          queue[tail] := neighbor;
          Inc(tail);
        end;
    end;
  end;

  if not found then
  begin
    Result := False;
    Exit;
  end;

  { Восстанавливаем маршрут от найденной цели к стартовой позиции }
  current := targetPoint;
  while not ((current.x = startX) and (current.y = startY)) do
  begin
    Path[current.x, current.y] := True;
    current := Parent[current.x, current.y];
  end;
  Path[startX, startY] := True;
  Result := True;
end;

{ Находит случайную стартовую позицию (внутри лабиринта, не на стене) }
procedure FindRandomStart(var x, y: Integer; floor: TFloor);
begin
  repeat
    x := Random(HEIGHT - 2) + 2;
    y := Random(WIDTH - 2) + 2;
  until floor[x, y] = ' ';
end;

{ Навигация по этажу:
  Если найден путь до цели (target), выводится кратчайший маршрут }
procedure NavigateFloor(var floor: TFloor; startX, startY: Integer; target: Char);
begin
  ResetArrays;
  if BFSPath(floor, startX, startY, target) then
  begin
    PrintPath(floor, startX, startY, target);
    Writeln;
  end
  else
    Writeln('Путь не найден');
end;

var
  startX, startY: Integer;
  randomC, randomJ: Integer;

begin
  For povt := 1 to 30 do
  begin
  Randomize;
  PrintIntro;

  { Выбираем этаж случайным образом }
  CurrentFloor := Random(3) + 1;
  case CurrentFloor of
    1:
      begin
        Writeln('=== Вы на 1 этаже ===');
        FindRandomStart(startX, startY, Floor1);
        NavigateFloor(Floor1, startX, startY, 'P');
      end;
    2:
      begin
        Writeln('=== Вы на 2 этаже ===');
        FindRandomStart(startX, startY, Floor2);
        NavigateFloor(Floor2, startX, startY, 'E');
        Writeln('=== Переход на 1 этаж ===');
        randomJ := Random(2) + 1;
        { Здесь можно задать фиксированные координаты перехода (например, угловые) }
        if randomJ = 1 then
        begin
          startX := 2;  { верхний левый угол игровой области }
          startY := 2;
        end
        else
        begin
          startX := 14; { нижний правый угол игровой области }
          startY := 14;
        end;
        NavigateFloor(Floor1, startX, startY, 'P');
      end;
    3:
      begin
        Writeln('=== Вы на 3 этаже ===');
        FindRandomStart(startX, startY, Floor3);
        if BFSPath(Floor3, startX, startY, 'S') then
        begin
          PrintPath(Floor3, startX, startY, 'S');
          Writeln('=== Переход на 2 этаж ===');
          randomC := Random(2) + 1;
          if randomC = 1 then
          begin
            startX := 2;  { верхний левый угол игровой области }
            startY := 14; { верхний правый угол }
          end
          else
          begin
            startX := 14; { нижний левый угол }
            startY := 2;  { нижний правый угол }
          end;
          NavigateFloor(Floor2, startX, startY, 'E');

          Writeln('=== Переход на 1 этаж ===');
          randomJ := Random(2) + 1;
          if randomJ = 1 then
          begin
            startX := 2;
            startY := 2;
          end
          else
          begin
            startX := 14;
            startY := 14;
          end;
          NavigateFloor(Floor1, startX, startY, 'P');
        end
        else
          Writeln('Путь к S не найден');
      end;
  end;
  Readln;
  readln;
  end;
end.

