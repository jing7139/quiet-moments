// GENERATED CODE — stub for prototyping.
// Run `dart run build_runner build` to replace with real adapter.
part of 'reminder_config.dart';

class ReminderConfigAdapter extends TypeAdapter<ReminderConfig> {
  @override
  final int typeId = 1;

  @override
  ReminderConfig read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return ReminderConfig(
      sedentaryIntervalMinutes: fields[0] as int? ?? 45,
      hydrationIntervalMinutes: fields[1] as int? ?? 60,
      quietMode: fields[2] as bool? ?? true,
      quietStart: fields[3] as String? ?? '22:00',
      quietEnd: fields[4] as String? ?? '08:00',
      normalSound: fields[5] as bool? ?? false,
      normalVibrate: fields[6] as bool? ?? true,
      urgentSound: fields[7] as bool? ?? true,
      urgentVibrate: fields[8] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderConfig obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.sedentaryIntervalMinutes);
    writer.writeByte(1);
    writer.write(obj.hydrationIntervalMinutes);
    writer.writeByte(2);
    writer.write(obj.quietMode);
    writer.writeByte(3);
    writer.write(obj.quietStart);
    writer.writeByte(4);
    writer.write(obj.quietEnd);
    writer.writeByte(5);
    writer.write(obj.normalSound);
    writer.writeByte(6);
    writer.write(obj.normalVibrate);
    writer.writeByte(7);
    writer.write(obj.urgentSound);
    writer.writeByte(8);
    writer.write(obj.urgentVibrate);
  }
}
