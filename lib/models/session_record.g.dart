// GENERATED CODE — stub for prototyping.
// Run `dart run build_runner build` to replace with real adapter.
part of 'session_record.dart';

class SessionRecordAdapter extends TypeAdapter<SessionRecord> {
  @override
  final int typeId = 0;

  @override
  SessionRecord read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return SessionRecord(
      date: fields[0] as DateTime? ?? DateTime.now(),
      totalSitsMinutes: fields[1] as int? ?? 0,
      standBreaks: fields[2] as int? ?? 0,
      hydrationCount: fields[3] as int? ?? 0,
      stretchMinutes: fields[4] as int? ?? 0,
      breathingMinutes: fields[5] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, SessionRecord obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.write(obj.date);
    writer.writeByte(1);
    writer.write(obj.totalSitsMinutes);
    writer.writeByte(2);
    writer.write(obj.standBreaks);
    writer.writeByte(3);
    writer.write(obj.hydrationCount);
    writer.writeByte(4);
    writer.write(obj.stretchMinutes);
    writer.writeByte(5);
    writer.write(obj.breathingMinutes);
  }
}
