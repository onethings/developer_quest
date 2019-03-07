import 'package:dev_rpg/src/game_screen/skill_badge.dart';
import 'package:dev_rpg/src/game_screen/team_picker_modal.dart';
import 'package:dev_rpg/src/shared_state/game/npc.dart';
import 'package:dev_rpg/src/shared_state/game/skill.dart';
import 'package:dev_rpg/src/shared_state/game/task.dart';
import 'package:dev_rpg/src/shared_state/provider.dart';
import 'package:flutter/material.dart';

/// Displays a [Task] that can be tapped on to assign it to a team.
/// The task can also be tapped on to award points once it is completed.
class TaskListItem extends StatelessWidget {
  final Task task;

  TaskListItem({@required this.task, Key key}) : super(key: key);

  void _handleTap(BuildContext context, Task task) async {
    switch (task.state) {
      case TaskState.completed:
        task.collectReward();
        break;
      case TaskState.working:
        var npcs = await showModalBottomSheet<Set<Npc>>(
          context: context,
          builder: (context) => TeamPickerModal(task),
        );
        _onAssigned(task, npcs);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Provide<Task>(
          builder: (context, child, task) => Card(
                color: task.state == TaskState.rewarded
                    ? Colors.grey
                    : Colors.white,
                child: (InkWell(
                  onTap: () => _handleTap(context, task),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Text(task.blueprint.name,
                                  style: TextStyle(fontSize: 14)),
                              task.state != TaskState.completed
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.only(left: 5.0),
                                      padding: EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      child: Text(
                                        "REWARD!!",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black),
                                      ),
                                    ),
                              Expanded(
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  children: task.blueprint.skillsNeeded
                                      .map((Skill skill) => SkillBadge(skill))
                                      .toList(),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: LinearProgressIndicator(
                              value: task.percentComplete),
                        ),
                        task.assignedTeam == null
                            ? SizedBox()
                            : Container(
                                height: 100.0,
                                color: Colors.deepOrange,
                                child: InkWell(
                                  onTap: () => task.boost += 2.5,
                                  child: Text(
                                      'Team Pic Goes Here... assigned to: '
                                      '${task.assignedTeam}. Tap to boost.'),
                                ),
                              )
                      ]),
                )),
              ),
        ));
  }

  void _onAssigned(Task task, Set<Npc> value) {
    if (value == null || value.isEmpty) return;
    task.assignTeam(value);
  }
}
