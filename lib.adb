pragma Style_Checks ("N3aAbcdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with Ada.Text_IO;
with RFLX.RFLX_Types;
with RFLX.Test.Session;
with Func;

package body Lib with
  SPARK_Mode
is

   function Image (Chan : RFLX.Test.Session.Channel) return String is
     ((case Chan is
          when RFLX.Test.Session.C_Channel =>
             "Channel"));

   procedure Print (Prefix : String; Buffer : RFLX.RFLX_Types.Bytes) is
   begin
      Ada.Text_IO.Put (Prefix & ":");
      for B of Buffer loop
         Ada.Text_IO.Put (B'Image);
      end loop;
      Ada.Text_IO.New_Line;
   end Print;

   procedure Read (Ctx : Func.Context; Chan : RFLX.Test.Session.Channel) with
     Pre =>
       Func.Initialized (Ctx)
       and then Func.Has_Data (Ctx, Chan),
     Post =>
       Func.Initialized (Ctx)
   is
      use type RFLX.RFLX_Types.Index;
      use type RFLX.RFLX_Types.Length;
      Buffer : RFLX.RFLX_Types.Bytes (RFLX.RFLX_Types.Index'First .. RFLX.RFLX_Types.Index'First + 4095) := (others => 0);
   begin
      if Buffer'Length >= Func.Read_Buffer_Size (Ctx, Chan) then
         Func.Read (Ctx, Chan, Buffer (Buffer'First .. Buffer'First - 2 + RFLX.RFLX_Types.Index (Func.Read_Buffer_Size (Ctx, Chan) + 1)));
         Print ("Read " & Image (Chan), Buffer (Buffer'First .. Buffer'First - 2 + RFLX.RFLX_Types.Index (Func.Read_Buffer_Size (Ctx, Chan) + 1)));
      else
         Ada.Text_IO.Put_Line ("Read " & Chan'Image & ": buffer too small");
      end if;
   end Read;

   type Number_Per_Channel is array (RFLX.Test.Session.Channel) of Natural;

   Written_Messages : Number_Per_Channel := (others => 0);

   function Next_Message (Chan : RFLX.Test.Session.Channel) return RFLX.RFLX_Types.Bytes is
      None : constant RFLX.RFLX_Types.Bytes (1 .. 0) := (others => 0);
      Message : constant RFLX.RFLX_Types.Bytes := (if Written_Messages (Chan) = 0 then (1, 0, 3, 0, 1, 2) else None);
   begin
      return Message;
   end Next_Message;

   procedure Write (Ctx : in out Func.Context; Chan : RFLX.Test.Session.Channel) with
     Pre =>
       Func.Initialized (Ctx)
       and then Func.Needs_Data (Ctx, Chan),
     Post =>
       Func.Initialized (Ctx)
   is
      use type RFLX.RFLX_Types.Length;
      Message : constant RFLX.RFLX_Types.Bytes := Next_Message (Chan);
   begin
      if
         Message'Length > 0
         and Message'Length <= Func.Write_Buffer_Size (Ctx, Chan)
      then
         Print ("Write " & Image (Chan), Message);
         Func.Write (Ctx, Chan, Message);
         if Written_Messages (Chan) < Natural'Last then
            Written_Messages (Chan) := Written_Messages (Chan) + 1;
         end if;
      end if;
   end Write;

   procedure Run is
      Ctx : Func.Context;
   begin
      Func.Initialize (Ctx);
      while Func.Active (Ctx) loop
         pragma Loop_Invariant (Func.Initialized (Ctx));
         for C in RFLX.Test.Session.Channel'Range loop
            pragma Loop_Invariant (Func.Initialized (Ctx));
            if Func.Has_Data (Ctx, C) then
               Read (Ctx, C);
            end if;
            if Func.Needs_Data (Ctx, C) then
               Write (Ctx, C);
            end if;
         end loop;
         Func.Run (Ctx);
      end loop;
      Func.Finalize (Ctx);
   end Run;

end Lib;
