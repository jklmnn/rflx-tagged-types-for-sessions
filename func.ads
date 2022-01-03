pragma Style_Checks ("N3aAbcdefhiIklnOprStux");

with RFLX.RFLX_Types;
with RFLX.Universal;
with RFLX.Fixed_Size.Simple_Message;
with RFLX.Test.Session;

package Func with
   SPARK_Mode
is

   type Context is new RFLX.Test.Session.Context with private;

   overriding
   procedure Get_Message_Type
      (Ctx    : in out Context;
       Result :    out RFLX.Universal.Option_Type)
   with
     Pre =>
       not Result'Constrained;

   overriding
   procedure Create_Message
      (Ctx          : in out Context;
       Result       :    out RFLX.Fixed_Size.Simple_Message.Structure;
       Message_Type :        RFLX.Universal.Option_Type;
       Data         :        RFLX.RFLX_Types.Bytes);

   overriding
   procedure Valid_Message
      (Ctx           : in out Context;
       Valid_Message :    out Boolean;
       Message_Type  :        RFLX.Universal.Option_Type;
       Strict        :        Boolean);

private

   type Context is new RFLX.Test.Session.Context with null record;

end Func;
