with Lib;
pragma Elaborate (Lib);

procedure Main with
   SPARK_Mode
is
begin
   Lib.Run;
end Main;
