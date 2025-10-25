import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/time_slot.dart';

class BarberScheduleScreen extends StatefulWidget {
  const BarberScheduleScreen({super.key});

  @override
  State<BarberScheduleScreen> createState() => _BarberScheduleScreenState();
}

class _BarberScheduleScreenState extends State<BarberScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<TimeSlot> _timeSlots = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
          tooltip: 'Về trang chủ',
        ),
        title: const Text('Lịch trình của tôi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Date picker
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ],
            ),
          ),
          
          // Time slots list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final slot = _timeSlots[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: slot.isAvailable 
                          ? Colors.green 
                          : Colors.red,
                      child: Icon(
                        slot.isAvailable ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(slot.timeRange),
                    subtitle: Text(slot.notes ?? 'Không có ghi chú'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTimeSlot(slot),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTimeSlot(slot),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTimeSlot,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      // TODO: Load time slots for selected date
    }
  }

  void _addTimeSlot() {
    showDialog(
      context: context,
      builder: (context) => AddTimeSlotDialog(
        selectedDate: _selectedDate,
        onTimeSlotAdded: (timeSlot) {
          setState(() {
            _timeSlots.add(timeSlot);
          });
        },
      ),
    );
  }

  void _editTimeSlot(TimeSlot slot) {
    showDialog(
      context: context,
      builder: (context) => EditTimeSlotDialog(
        timeSlot: slot,
        onTimeSlotUpdated: (updatedSlot) {
          setState(() {
            final index = _timeSlots.indexWhere((s) => s.id == slot.id);
            if (index != -1) {
              _timeSlots[index] = updatedSlot;
            }
          });
        },
      ),
    );
  }

  void _deleteTimeSlot(TimeSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa khung giờ'),
        content: const Text('Bạn có chắc chắn muốn xóa khung giờ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _timeSlots.removeWhere((s) => s.id == slot.id);
              });
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class AddTimeSlotDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(TimeSlot) onTimeSlotAdded;

  const AddTimeSlotDialog({
    super.key,
    required this.selectedDate,
    required this.onTimeSlotAdded,
  });

  @override
  State<AddTimeSlotDialog> createState() => _AddTimeSlotDialogState();
}

class _AddTimeSlotDialogState extends State<AddTimeSlotDialog> {
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _notesController = TextEditingController();
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm khung giờ'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Giờ bắt đầu'),
            subtitle: Text(_startTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: _selectStartTime,
          ),
          ListTile(
            title: const Text('Giờ kết thúc'),
            subtitle: Text(_endTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: _selectEndTime,
          ),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (tùy chọn)',
            ),
          ),
          SwitchListTile(
            title: const Text('Có sẵn'),
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: _saveTimeSlot,
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  void _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  void _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  void _saveTimeSlot() {
    final startDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    
    final endDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final timeSlot = TimeSlot(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
      barberId: 1, // TODO: Get from auth provider
      startTime: startDateTime,
      endTime: endDateTime,
      isAvailable: _isAvailable,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: DateTime.now(),
    );

    widget.onTimeSlotAdded(timeSlot);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

class EditTimeSlotDialog extends StatefulWidget {
  final TimeSlot timeSlot;
  final Function(TimeSlot) onTimeSlotUpdated;

  const EditTimeSlotDialog({
    super.key,
    required this.timeSlot,
    required this.onTimeSlotUpdated,
  });

  @override
  State<EditTimeSlotDialog> createState() => _EditTimeSlotDialogState();
}

class _EditTimeSlotDialogState extends State<EditTimeSlotDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TextEditingController _notesController;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.fromDateTime(widget.timeSlot.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.timeSlot.endTime);
    _notesController = TextEditingController(text: widget.timeSlot.notes ?? '');
    _isAvailable = widget.timeSlot.isAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa khung giờ'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Giờ bắt đầu'),
            subtitle: Text(_startTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: _selectStartTime,
          ),
          ListTile(
            title: const Text('Giờ kết thúc'),
            subtitle: Text(_endTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: _selectEndTime,
          ),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (tùy chọn)',
            ),
          ),
          SwitchListTile(
            title: const Text('Có sẵn'),
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: _updateTimeSlot,
          child: const Text('Cập nhật'),
        ),
      ],
    );
  }

  void _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  void _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  void _updateTimeSlot() {
    final startDateTime = DateTime(
      widget.timeSlot.startTime.year,
      widget.timeSlot.startTime.month,
      widget.timeSlot.startTime.day,
      _startTime.hour,
      _startTime.minute,
    );
    
    final endDateTime = DateTime(
      widget.timeSlot.endTime.year,
      widget.timeSlot.endTime.month,
      widget.timeSlot.endTime.day,
      _endTime.hour,
      _endTime.minute,
    );

    final updatedSlot = TimeSlot(
      id: widget.timeSlot.id,
      barberId: widget.timeSlot.barberId,
      startTime: startDateTime,
      endTime: endDateTime,
      isAvailable: _isAvailable,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: widget.timeSlot.createdAt,
    );

    widget.onTimeSlotUpdated(updatedSlot);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
