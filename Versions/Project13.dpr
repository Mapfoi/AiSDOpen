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

{ ���������� ������� ����������� (�����, ����, �����, ������) }
var
  dx: array [1 .. 4] of Integer = (-1, 1, 0, 0);
  dy: array [1 .. 4] of Integer = (0, 0, -1, 1);

{ ����� ����������� � ������� ����� }
procedure PrintIntro;
begin
  Writeln('��� �������� ���������!');
  Writeln('�� ���������� ���� ��������������. ���� ��������� �����, �� ������� ������� ������� �� ������.');
  Writeln;
  Writeln('������� �����:');
  Writeln('  # - �����');
  Writeln('  (������) - ��������� ������������');
  Writeln('  S - �������� �� 3 ����� (����� � 3-�� �����)');
  Writeln('  E - ����� �� 2 ����� (����� � 2-�� �����)');
  Writeln('  P - ����� � 1 �����');
  Writeln('  J - ����� ��������� �� 1 �����');
  Writeln('  X - ���� ������� ��������������');
  Writeln;
  Writeln('�������� �����, ����� ��������!');
  Writeln('������� Enter ��� ������...');
  Readln;
end;

{ ���������� ������� ��� ������� ���������� ������ � �������� }
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

{ ����� ��������.
  ���� ������ �������� ���������, ��������� "X".
  ���� ������ ������ � ��������� ����, ��������� ����������� ������,
  �� ����������� ������, ����� ��� ������ ��� �������� ������� ������. }
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

{ ���������� BFS ��� ������ ����������� ����.
  ���� ���� �� ������� target ������, ������� ��������������� ���,
  ������� ������ �������� � ������� Path. }
function BFSPath(var floor: TFloor; startX, startY: Integer; target: Char): Boolean;
var
  queue: array of TPoint;
  head, tail, i, nx, ny: Integer;
  current, neighbor, targetPoint: TPoint;
  found: Boolean;
  Parent: array [1 .. HEIGHT, 1 .. WIDTH] of TPoint;
begin
  ResetArrays;
  { �������������� ������ }
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

  { ��������������� ������� �� ��������� ���� � ��������� ������� }
  current := targetPoint;
  while not ((current.x = startX) and (current.y = startY)) do
  begin
    Path[current.x, current.y] := True;
    current := Parent[current.x, current.y];
  end;
  Path[startX, startY] := True;
  Result := True;
end;

{ ������� ��������� ��������� ������� (������ ���������, �� �� �����) }
procedure FindRandomStart(var x, y: Integer; floor: TFloor);
begin
  repeat
    x := Random(HEIGHT - 2) + 2;
    y := Random(WIDTH - 2) + 2;
  until floor[x, y] = ' ';
end;

{ ��������� �� �����:
  ���� ������ ���� �� ���� (target), ��������� ���������� ������� }
procedure NavigateFloor(var floor: TFloor; startX, startY: Integer; target: Char);
begin
  ResetArrays;
  if BFSPath(floor, startX, startY, target) then
  begin
    PrintPath(floor, startX, startY, target);
    Writeln;
  end
  else
    Writeln('���� �� ������');
end;

var
  startX, startY: Integer;
  randomC, randomJ: Integer;

begin
  For povt := 1 to 30 do
  begin
  Randomize;
  PrintIntro;

  { �������� ���� ��������� ������� }
  CurrentFloor := Random(3) + 1;
  case CurrentFloor of
    1:
      begin
        Writeln('=== �� �� 1 ����� ===');
        FindRandomStart(startX, startY, Floor1);
        NavigateFloor(Floor1, startX, startY, 'P');
      end;
    2:
      begin
        Writeln('=== �� �� 2 ����� ===');
        FindRandomStart(startX, startY, Floor2);
        NavigateFloor(Floor2, startX, startY, 'E');
        Writeln('=== ������� �� 1 ���� ===');
        randomJ := Random(2) + 1;
        { ����� ����� ������ ������������� ���������� �������� (��������, �������) }
        if randomJ = 1 then
        begin
          startX := 2;  { ������� ����� ���� ������� ������� }
          startY := 2;
        end
        else
        begin
          startX := 14; { ������ ������ ���� ������� ������� }
          startY := 14;
        end;
        NavigateFloor(Floor1, startX, startY, 'P');
      end;
    3:
      begin
        Writeln('=== �� �� 3 ����� ===');
        FindRandomStart(startX, startY, Floor3);
        if BFSPath(Floor3, startX, startY, 'S') then
        begin
          PrintPath(Floor3, startX, startY, 'S');
          Writeln('=== ������� �� 2 ���� ===');
          randomC := Random(2) + 1;
          if randomC = 1 then
          begin
            startX := 2;  { ������� ����� ���� ������� ������� }
            startY := 14; { ������� ������ ���� }
          end
          else
          begin
            startX := 14; { ������ ����� ���� }
            startY := 2;  { ������ ������ ���� }
          end;
          NavigateFloor(Floor2, startX, startY, 'E');

          Writeln('=== ������� �� 1 ���� ===');
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
          Writeln('���� � S �� ������');
      end;
  end;
  Readln;
  readln;
  end;
end.

