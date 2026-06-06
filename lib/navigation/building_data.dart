import 'dart:math';

import 'models.dart';

class BuildingData {
  static const double buildingWidth = 30.0;
  static const double buildingDepth = 29.0;

  static const List<Room> groundFloor = [
    Room(id: 'G_STAIRS_N', name: 'North Stairs', shortName: 'درج', type: RoomType.stairs, floor: 0, x: 11.5, y: 3.5, w: 3, h: 2.5),
    Room(id: 'G_ELEV_N', name: 'North Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 0, x: 15, y: 3.5, w: 3, h: 2.5),
    Room(id: 'G_WORKSHOP', name: 'Workshop B (ورشة ب)', shortName: 'ورشة ب', type: RoomType.lab, floor: 0, x: 2.5, y: 18, w: 5, h: 5),
    Room(id: 'G_HALL', name: 'Main Hall (القاعة الرئيسية)', shortName: 'القاعة\nالرئيسية', type: RoomType.room, floor: 0, x: 22.5, y: 18, w: 5, h: 5),
    Room(id: 'G_ELEV_S', name: 'South Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 0, x: 11.5, y: 23, w: 3, h: 2.5),
    Room(id: 'G_STAIRS_S', name: 'South Stairs', shortName: 'درج', type: RoomType.stairs, floor: 0, x: 15, y: 23, w: 3, h: 2.5),
    Room(id: 'G_ENTRANCE_S', name: 'South Entrance (المدخل الجنوبي)', shortName: 'المدخل\nالجنوبي', type: RoomType.entrance, floor: 0, x: 27.5, y: 8, w: 2.5, h: 10),
    Room(id: 'G_ENTRANCE_W', name: 'West Entrance (المدخل الغربي)', shortName: 'المدخل\nالغربي', type: RoomType.entrance, floor: 0, x: 10, y: 26, w: 10, h: 2.5),
    Room(id: 'G_ENTRANCE_E', name: 'East Entrance (المدخل الشرقي)', shortName: 'المدخل الشرقي', type: RoomType.entrance, floor: 0, x: 10, y: 0.5, w: 10, h: 2.5),
  ];

  static const List<Room> firstFloor = [
    Room(id: 'F1_WC_N', name: 'Restroom North (F1)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 1, x: 8, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F1_STAIRS_N', name: 'North Stairs', shortName: 'درج', type: RoomType.stairs, floor: 1, x: 11.5, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F1_ELEV_N', name: 'North Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 1, x: 15, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F1_EMRG_N', name: 'Emergency Exit North (F1)', shortName: 'مخرج\nطوارئ', type: RoomType.entrance, floor: 1, x: 18.5, y: 0.5, w: 4, h: 2.5),
    Room(id: 'F1_H3', name: '1.03 - Hall (قاعة)', shortName: 'قاعة\n1.03', type: RoomType.lectureHall, floor: 1, x: 0.5, y: 3, w: 7, h: 5),
    Room(id: 'F1_H16', name: '1.16 - Hall (قاعة)', shortName: 'قاعة\n1.16', type: RoomType.lectureHall, floor: 1, x: 22.5, y: 3, w: 7, h: 5),
    Room(id: 'F1_WC_WU', name: 'Restroom West-Upper (F1)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 1, x: 0.5, y: 8, w: 7, h: 2.5),
    Room(id: 'F1_WC_EU', name: 'Restroom East-Upper (F1)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 1, x: 22.5, y: 8, w: 7, h: 2.5),
    Room(id: 'F1_H5', name: '1.05 - Hall (قاعة)', shortName: 'قاعة\n1.05', type: RoomType.lectureHall, floor: 1, x: 0.5, y: 10.5, w: 7, h: 2.5),
    Room(id: 'F1_H19', name: '1.19 - Hall (قاعة)', shortName: 'قاعة\n1.19', type: RoomType.lectureHall, floor: 1, x: 10, y: 10.5, w: 10, h: 2.5),
    Room(id: 'F1_H14', name: '1.14 - Hall (قاعة)', shortName: 'قاعة\n1.14', type: RoomType.lectureHall, floor: 1, x: 22.5, y: 10.5, w: 7, h: 2.5),
    Room(id: 'F1_H6', name: '1.06 - Hall (قاعة)', shortName: 'قاعة\n1.06', type: RoomType.lectureHall, floor: 1, x: 0.5, y: 13, w: 7, h: 2.5),
    Room(id: 'F1_H20', name: '1.20 - Hall (قاعة)', shortName: 'قاعة\n1.20', type: RoomType.lectureHall, floor: 1, x: 10, y: 13, w: 10, h: 2.5),
    Room(id: 'F1_H13', name: '1.13 - Hall (قاعة)', shortName: 'قاعة\n1.13', type: RoomType.lectureHall, floor: 1, x: 22.5, y: 13, w: 7, h: 2.5),
    Room(id: 'F1_WC_WL', name: 'Restroom West-Lower (F1)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 1, x: 0.5, y: 15.5, w: 7, h: 2.5),
    Room(id: 'F1_WC_EL', name: 'Restroom East-Lower (F1)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 1, x: 22.5, y: 15.5, w: 7, h: 2.5),
    Room(id: 'F1_LAB8', name: '1.08 - Hall (قاعة)', shortName: 'قاعة\n1.08', type: RoomType.lectureHall, floor: 1, x: 0.5, y: 18, w: 7, h: 5),
    Room(id: 'F1_LAB11', name: '1.11 - Hall (قاعة)', shortName: 'قاعة\n1.11', type: RoomType.lectureHall, floor: 1, x: 22.5, y: 18, w: 7, h: 5),
    Room(id: 'F1_WC_S', name: 'Restroom South (F1)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 1, x: 8, y: 23, w: 3, h: 2.5),
    Room(id: 'F1_ELEV_S', name: 'South Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 1, x: 11.5, y: 23, w: 3, h: 2.5),
    Room(id: 'F1_STAIRS_S', name: 'South Stairs', shortName: 'درج', type: RoomType.stairs, floor: 1, x: 15, y: 23, w: 3, h: 2.5),
    Room(id: 'F1_EMRG_S', name: 'Emergency Exit South (F1)', shortName: 'مخرج\nطوارئ', type: RoomType.entrance, floor: 1, x: 18.5, y: 23, w: 4, h: 2.5),
  ];

  static const List<Room> secondFloor = [
    Room(id: 'F2_WC_N', name: 'Restroom North (F2)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 2, x: 8, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F2_STAIRS_N', name: 'North Stairs', shortName: 'درج', type: RoomType.stairs, floor: 2, x: 11.5, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F2_ELEV_N', name: 'North Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 2, x: 15, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F2_EMRG_N', name: 'Emergency Exit North (F2)', shortName: 'مخرج\nطوارئ', type: RoomType.entrance, floor: 2, x: 18.5, y: 0.5, w: 4, h: 2.5),
    Room(id: 'F2_H3', name: '2.03 - Hall (قاعة)', shortName: 'قاعة\n2.03', type: RoomType.lectureHall, floor: 2, x: 0.5, y: 3, w: 7, h: 5),
    Room(id: 'F2_H17', name: '2.17 - Hall (قاعة)', shortName: 'قاعة\n2.17', type: RoomType.lectureHall, floor: 2, x: 22.5, y: 3, w: 7, h: 5),
    Room(id: 'F2_WC_WU', name: 'Restroom West-Upper (F2)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 2, x: 0.5, y: 8, w: 7, h: 2.5),
    Room(id: 'F2_WC_EU', name: 'Restroom East-Upper (F2)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 2, x: 22.5, y: 8, w: 7, h: 2.5),
    Room(id: 'F2_H5', name: '2.05 - Hall (قاعة)', shortName: 'قاعة\n2.05', type: RoomType.lectureHall, floor: 2, x: 0.5, y: 10.5, w: 7, h: 2.5),
    Room(id: 'F2_H20', name: '2.20 - Hall (قاعة)', shortName: 'قاعة\n2.20', type: RoomType.lectureHall, floor: 2, x: 10, y: 10.5, w: 10, h: 2.5),
    Room(id: 'F2_H15', name: '2.15 - Hall (قاعة)', shortName: 'قاعة\n2.15', type: RoomType.lectureHall, floor: 2, x: 22.5, y: 10.5, w: 7, h: 2.5),
    Room(id: 'F2_H6', name: '2.06 - Hall (قاعة)', shortName: 'قاعة\n2.06', type: RoomType.lectureHall, floor: 2, x: 0.5, y: 13, w: 7, h: 2.5),
    Room(id: 'F2_H21', name: '2.21 - Hall (قاعة)', shortName: 'قاعة\n2.21', type: RoomType.lectureHall, floor: 2, x: 10, y: 13, w: 10, h: 2.5),
    Room(id: 'F2_H14', name: '2.14 - Hall (قاعة)', shortName: 'قاعة\n2.14', type: RoomType.lectureHall, floor: 2, x: 22.5, y: 13, w: 7, h: 2.5),
    Room(id: 'F2_WC_WL', name: 'Restroom West-Lower (F2)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 2, x: 0.5, y: 15.5, w: 7, h: 2.5),
    Room(id: 'F2_WC_EL', name: 'Restroom East-Lower (F2)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 2, x: 22.5, y: 15.5, w: 7, h: 2.5),
    Room(id: 'F2_H8', name: '2.08 - Hall (قاعة)', shortName: 'قاعة\n2.08', type: RoomType.lectureHall, floor: 2, x: 0.5, y: 18, w: 7, h: 2.5),
    Room(id: 'F2_H9', name: '2.09 - Hall (قاعة)', shortName: 'قاعة\n2.09', type: RoomType.lectureHall, floor: 2, x: 0.5, y: 20.5, w: 7, h: 2.5),
    Room(id: 'F2_H13', name: '2.13 - Hall (قاعة)', shortName: 'قاعة\n2.13', type: RoomType.lectureHall, floor: 2, x: 22.5, y: 18, w: 7, h: 2.5),
    Room(id: 'F2_H12', name: '2.12 - Hall (قاعة)', shortName: 'قاعة\n2.12', type: RoomType.lectureHall, floor: 2, x: 22.5, y: 20.5, w: 7, h: 2.5),
    Room(id: 'F2_WC_S', name: 'Restroom South (F2)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 2, x: 8, y: 23, w: 3, h: 2.5),
    Room(id: 'F2_ELEV_S', name: 'South Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 2, x: 11.5, y: 23, w: 3, h: 2.5),
    Room(id: 'F2_STAIRS_S', name: 'South Stairs', shortName: 'درج', type: RoomType.stairs, floor: 2, x: 15, y: 23, w: 3, h: 2.5),
    Room(id: 'F2_EMRG_S', name: 'Emergency Exit South (F2)', shortName: 'مخرج\nطوارئ', type: RoomType.entrance, floor: 2, x: 18.5, y: 23, w: 4, h: 2.5),
  ];

  static const List<Room> thirdFloor = [
    Room(id: 'F3_WC_N', name: 'Restroom North (F3)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 3, x: 8, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F3_STAIRS_N', name: 'North Stairs', shortName: 'درج', type: RoomType.stairs, floor: 3, x: 11.5, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F3_ELEV_N', name: 'North Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 3, x: 15, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F3_EMRG_N', name: 'Emergency Exit North (F3)', shortName: 'مخرج\nطوارئ', type: RoomType.entrance, floor: 3, x: 18.5, y: 0.5, w: 4, h: 2.5),
    Room(id: 'F3_H13', name: '3.13 - Hall (قاعة)', shortName: 'قاعة\n3.13', type: RoomType.lectureHall, floor: 3, x: 0.5, y: 3, w: 7, h: 2.5),
    Room(id: 'F3_H14', name: '3.14 - Hall (قاعة)', shortName: 'قاعة\n3.14', type: RoomType.lectureHall, floor: 3, x: 0.5, y: 5.5, w: 7, h: 2.5),
    Room(id: 'F3_H10', name: '3.10 - Hall (قاعة)', shortName: 'قاعة\n3.10', type: RoomType.lectureHall, floor: 3, x: 22.5, y: 3, w: 7, h: 2.5),
    Room(id: 'F3_H9', name: '3.09 - Hall (قاعة)', shortName: 'قاعة\n3.09', type: RoomType.lectureHall, floor: 3, x: 22.5, y: 5.5, w: 7, h: 2.5),
    Room(id: 'F3_WC_WU', name: 'Restroom West-Upper (F3)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 3, x: 0.5, y: 8, w: 7, h: 2.5),
    Room(id: 'F3_WC_EU', name: 'Restroom East-Upper (F3)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 3, x: 22.5, y: 8, w: 7, h: 2.5),
    Room(id: 'F3_H16', name: '3.16 - Hall (قاعة)', shortName: 'قاعة\n3.16', type: RoomType.lectureHall, floor: 3, x: 0.5, y: 10.5, w: 7, h: 2.5),
    Room(id: 'F3_H24', name: '3.24 - Hall (قاعة)', shortName: 'قاعة\n3.24', type: RoomType.lectureHall, floor: 3, x: 10, y: 10.5, w: 10, h: 2.5),
    Room(id: 'F3_H7', name: '3.07 - Hall (قاعة)', shortName: 'قاعة\n3.07', type: RoomType.lectureHall, floor: 3, x: 22.5, y: 10.5, w: 7, h: 2.5),
    Room(id: 'F3_H17', name: '3.17 - Hall (قاعة)', shortName: 'قاعة\n3.17', type: RoomType.lectureHall, floor: 3, x: 0.5, y: 13, w: 7, h: 2.5),
    Room(id: 'F3_H23', name: '3.23 - Hall (قاعة)', shortName: 'قاعة\n3.23', type: RoomType.lectureHall, floor: 3, x: 10, y: 13, w: 10, h: 2.5),
    Room(id: 'F3_H6', name: '3.06 - Hall (قاعة)', shortName: 'قاعة\n3.06', type: RoomType.lectureHall, floor: 3, x: 22.5, y: 13, w: 7, h: 2.5),
    Room(id: 'F3_WC_WL', name: 'Restroom West-Lower (F3)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 3, x: 0.5, y: 15.5, w: 7, h: 2.5),
    Room(id: 'F3_WC_EL', name: 'Restroom East-Lower (F3)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 3, x: 22.5, y: 15.5, w: 7, h: 2.5),
    Room(id: 'F3_H19', name: '3.19 - Hall (قاعة)', shortName: 'قاعة\n3.19', type: RoomType.lectureHall, floor: 3, x: 0.5, y: 18, w: 7, h: 2.5),
    Room(id: 'F3_H20', name: '3.20 - Hall (قاعة)', shortName: 'قاعة\n3.20', type: RoomType.lectureHall, floor: 3, x: 0.5, y: 20.5, w: 7, h: 2.5),
    Room(id: 'F3_H4', name: '3.04 - Hall (قاعة)', shortName: 'قاعة\n3.04', type: RoomType.lectureHall, floor: 3, x: 22.5, y: 18, w: 7, h: 2.5),
    Room(id: 'F3_H3', name: '3.03 - Hall (قاعة)', shortName: 'قاعة\n3.03', type: RoomType.lectureHall, floor: 3, x: 22.5, y: 20.5, w: 7, h: 2.5),
    Room(id: 'F3_WC_S', name: 'Restroom South (F3)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 3, x: 8, y: 23, w: 3, h: 2.5),
    Room(id: 'F3_ELEV_S', name: 'South Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 3, x: 11.5, y: 23, w: 3, h: 2.5),
    Room(id: 'F3_STAIRS_S', name: 'South Stairs', shortName: 'درج', type: RoomType.stairs, floor: 3, x: 15, y: 23, w: 3, h: 2.5),
    Room(id: 'F3_EMRG_S', name: 'Emergency Exit South (F3)', shortName: 'مخرج\nطوارئ', type: RoomType.entrance, floor: 3, x: 18.5, y: 23, w: 4, h: 2.5),
  ];

  static const List<Room> fourthFloor = [
    Room(id: 'F4_WC_N', name: 'Restroom North (F4)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 4, x: 8, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F4_STAIRS_N', name: 'North Stairs', shortName: 'درج', type: RoomType.stairs, floor: 4, x: 11.5, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F4_ELEV_N', name: 'North Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 4, x: 15, y: 0.5, w: 3, h: 2.5),
    Room(id: 'F4_EMRG_N', name: 'Emergency Exit North (F4)', shortName: 'مخرج\nطوارئ', type: RoomType.entrance, floor: 4, x: 18.5, y: 0.5, w: 4, h: 2.5),
    Room(id: 'F4_ADMIN',     name: '4.01 - Admin Director (مكتب مدير الإدارة)',              shortName: '4.01\nمدير الإدارة',    type: RoomType.office,      floor: 4, x: 0.5,  y: 3,    w: 7, h: 2.5),
    Room(id: 'F4_HEAD_IME',  name: '4.02 - Head of Ind. & Mech. Eng. (رئيس قسم ص.م)',       shortName: '4.02\nرئيس قسم ص.م',   type: RoomType.office,      floor: 4, x: 22.5, y: 3,    w: 7, h: 2.5),
    Room(id: 'F4_HEAD_EE',   name: '4.03 - Head of Electrical Eng. (رئيس قسم كهربائية)',     shortName: '4.03\nرئيس كهربائية',  type: RoomType.office,      floor: 4, x: 0.5,  y: 5.5,  w: 7, h: 2.5),
    Room(id: 'F4_RECEP_N',   name: '4.04 - Reception North (استقبال)',                        shortName: '4.04\nاستقبال',         type: RoomType.office,      floor: 4, x: 10,   y: 5.5,  w: 5, h: 2.5),
    Room(id: 'F4_EMPTY_N',   name: '4.05 - Empty (فراغ)',                                     shortName: '4.05\nفراغ',            type: RoomType.room,        floor: 4, x: 15,   y: 5.5,  w: 5, h: 2.5),
    Room(id: 'F4_SEC_IME',   name: '4.06 - Secretary Ind. & Mech. Eng. (سكرتارية قسم ص.م)', shortName: '4.06\nسكرتارية',        type: RoomType.office,      floor: 4, x: 22.5, y: 5.5,  w: 5, h: 2.5),
    Room(id: 'F4_WC_ER',     name: 'Restroom East (F4)',                                       shortName: 'دورة مياه',             type: RoomType.restroom,    floor: 4, x: 27.5, y: 5.5,  w: 2, h: 2.5),
    Room(id: 'F4_WC_WU',     name: 'Restroom West-Upper (F4)',                                 shortName: 'دورة مياه',             type: RoomType.restroom,    floor: 4, x: 0.5,  y: 8,    w: 7, h: 2.5),
    Room(id: 'F4_WC_EU',     name: 'Restroom East-Upper (F4)',                                 shortName: 'دورة مياه',             type: RoomType.restroom,    floor: 4, x: 22.5, y: 8,    w: 7, h: 2.5),
    Room(id: 'F4_IT',        name: '4.07 - IT Support (مكتب الدعم الفني)',                    shortName: '4.07\nالدعم الفني',     type: RoomType.office,      floor: 4, x: 0.5,  y: 10.5, w: 7, h: 2.5),
    Room(id: 'F4_SEC_EE',    name: '4.08 - Electrical Eng. Secretary (سكرتارية كهربائية)',    shortName: '4.08\nسكرتارية',        type: RoomType.office,      floor: 4, x: 10,   y: 10.5, w: 5, h: 2.5),
    Room(id: 'F4_MAIL',      name: '4.09 - Mail Office (مكتب البريد)',                        shortName: '4.09\nمكتب البريد',     type: RoomType.office,      floor: 4, x: 15,   y: 10.5, w: 5, h: 2.5),
    Room(id: 'F4_MEETING',   name: '4.10 - Meeting Hall (قاعة اجتماعات)',                     shortName: '4.10\nاجتماعات',        type: RoomType.meetingRoom, floor: 4, x: 22.5, y: 10.5, w: 7, h: 2.5),
    Room(id: 'F4_STATIONERY',name: '4.11 - Stationery (قرطاسية)',                             shortName: '4.11\nقرطاسية',         type: RoomType.office,      floor: 4, x: 0.5,  y: 13,   w: 7, h: 2.5),
    Room(id: 'F4_STAT_ADMIN',name: '4.12 - Stationery Admin (إدارة القرطاسية)',               shortName: '4.12\nإدارة القرط.',    type: RoomType.office,      floor: 4, x: 10,   y: 13,   w: 5, h: 2.5),
    Room(id: 'F4_FIELD',     name: '4.13 - Field Services (الخدمات الميدانية)',               shortName: '4.13\nخدمات ميدانية',   type: RoomType.office,      floor: 4, x: 15,   y: 13,   w: 5, h: 2.5),
    Room(id: 'F4_COPY',      name: '4.14 - Copy Center (مركز التصوير)',                       shortName: '4.14\nمركز التصوير',    type: RoomType.office,      floor: 4, x: 22.5, y: 13,   w: 7, h: 2.5),
    Room(id: 'F4_WC_WL',     name: 'Restroom West-Lower (F4)',                                 shortName: 'دورة مياه',             type: RoomType.restroom,    floor: 4, x: 0.5,  y: 15.5, w: 7, h: 2.5),
    Room(id: 'F4_WC_EL',     name: 'Restroom East-Lower (F4)',                                 shortName: 'دورة مياه',             type: RoomType.restroom,    floor: 4, x: 22.5, y: 15.5, w: 7, h: 2.5),
    Room(id: 'F4_SEC_CS',    name: '4.15 - CS Secretary (سكرتارية حاسبات)',                   shortName: '4.15\nسكرتارية ح.',     type: RoomType.office,      floor: 4, x: 0.5,  y: 18,   w: 7, h: 2.5),
    Room(id: 'F4_EMPTY_S',   name: '4.16 - Empty (فراغ)',                                     shortName: '4.16\nفراغ',            type: RoomType.room,        floor: 4, x: 10,   y: 18,   w: 5, h: 2.5),
    Room(id: 'F4_RECEP_S',   name: '4.17 - Reception South (استقبال)',                        shortName: '4.17\nاستقبال',         type: RoomType.office,      floor: 4, x: 15,   y: 18,   w: 5, h: 2.5),
    Room(id: 'F4_SEC_ENV',   name: '4.18 - Env. Eng. Secretary (سكرتارية بيئية)',             shortName: '4.18\nسكرتارية ب.',     type: RoomType.office,      floor: 4, x: 22.5, y: 18,   w: 7, h: 2.5),
    Room(id: 'F4_HEAD_CS',   name: '4.19 - Head of CS (رئيس قسم الحاسبات)',                  shortName: '4.19\nرئيس الحاسبات',   type: RoomType.office,      floor: 4, x: 0.5,  y: 20.5, w: 7, h: 2.5),
    Room(id: 'F4_HEAD_ENV',  name: '4.20 - Head of Env. Eng. (رئيس قسم البيئية)',             shortName: '4.20\nرئيس البيئية',    type: RoomType.office,      floor: 4, x: 22.5, y: 20.5, w: 7, h: 2.5),
    Room(id: 'F4_WC_S', name: 'Restroom South (F4)', shortName: 'دورة مياه', type: RoomType.restroom, floor: 4, x: 8, y: 23, w: 3, h: 2.5),
    Room(id: 'F4_ELEV_S', name: 'South Elevator', shortName: 'مصعد', type: RoomType.elevator, floor: 4, x: 11.5, y: 23, w: 3, h: 2.5),
    Room(id: 'F4_STAIRS_S', name: 'South Stairs', shortName: 'درج', type: RoomType.stairs, floor: 4, x: 15, y: 23, w: 3, h: 2.5),
    Room(id: 'F4_EMRG_S', name: 'Emergency Exit South (F4)', shortName: 'مخرج\nطوارئ', type: RoomType.entrance, floor: 4, x: 18.5, y: 23, w: 4, h: 2.5),
  ];

  static List<Room> get allRooms => [
        ...groundFloor,
        ...firstFloor,
        ...secondFloor,
        ...thirdFloor,
        ...fourthFloor,
      ];

  static List<Room> get navigableRooms => allRooms.where((room) => room.isNavigable).toList();

  static List<Room> roomsForFloor(int floor) => allRooms.where((room) => room.floor == floor).toList();

  static const Map<String, String> _dbRoomMapping = {
    'القاعة 204':            'F2_H5',
    'مختبر الابتكار 2':      'F1_LAB8',
    'القاعة 118':            'F1_LAB11',
    'قاعة المحاضرات 4B':    'F1_H19',
    'مختبر الحوسبة 12':     'F2_H8',
    'القاعة 302':            'F3_H17',
    'قاعة المحاضرات 1':     'F1_H3',
    'قاعة المحاضرات 2':     'F1_H5',
    'قاعة المحاضرات 3':     'F1_H6',
    'قاعة المحاضرات 4':     'F1_H19',
    'مختبر الحوسبة':        'F2_H8',
    'مختبر الشبكات':        'F1_LAB8',
    'مختبر البرمجة':        'F1_LAB8',
    'مختبر الابتكار':       'F1_LAB8',
    'القاعة الرئيسية':      'G_HALL',
    'ورشة ب':               'G_WORKSHOP',
    'القاعة 103': 'F1_H3',   'القاعة 105': 'F1_H5',
    'القاعة 106': 'F1_H6',   'القاعة 108': 'F1_LAB8',
    'القاعة 111': 'F1_LAB11','القاعة 113': 'F1_H13',
    'القاعة 114': 'F1_H14',  'القاعة 116': 'F1_H16',
    'القاعة 119': 'F1_H19',  'القاعة 120': 'F1_H20',
    'القاعة 203': 'F2_H3',   'القاعة 205': 'F2_H5',
    'القاعة 206': 'F2_H6',   'القاعة 208': 'F2_H8',
    'القاعة 209': 'F2_H9',   'القاعة 212': 'F2_H12',
    'القاعة 213': 'F2_H13',  'القاعة 214': 'F2_H14',
    'القاعة 215': 'F2_H15',  'القاعة 217': 'F2_H17',
    'القاعة 220': 'F2_H20',  'القاعة 221': 'F2_H21',
    'القاعة 303': 'F3_H3',   'القاعة 304': 'F3_H4',
    'القاعة 306': 'F3_H6',   'القاعة 307': 'F3_H7',
    'القاعة 309': 'F3_H9',   'القاعة 310': 'F3_H10',
    'القاعة 313': 'F3_H13',  'القاعة 314': 'F3_H14',
    'القاعة 316': 'F3_H16',  'القاعة 319': 'F3_H19',
    'القاعة 320': 'F3_H20',  'القاعة 323': 'F3_H23',
    'القاعة 324': 'F3_H24',
  };

  static String? resolveRoomId(String dbRoomName) {
    final trimmed = dbRoomName.trim();
    if (_dbRoomMapping.containsKey(trimmed)) return _dbRoomMapping[trimmed];
    for (final entry in _dbRoomMapping.entries) {
      if (trimmed.contains(entry.key) || entry.key.contains(trimmed)) return entry.value;
    }
    final numMatch = RegExp(r'(\d)(\d{2})').firstMatch(trimmed);
    if (numMatch != null) {
      final floor = int.tryParse(numMatch.group(1)!) ?? 0;
      final roomStr = '${numMatch.group(1)}.${numMatch.group(2)}';
      for (final room in navigableRooms) {
        if (room.floor == floor && room.name.contains(roomStr)) return room.id;
      }
    }
    if (trimmed.contains('مختبر') || trimmed.contains('Lab') || trimmed.contains('lab')) {
      final numMatch2 = RegExp(r'\d+').firstMatch(trimmed);
      if (numMatch2 != null) {
        for (final room in navigableRooms) {
          if (room.type.name.contains('lab') && room.shortName.contains(numMatch2.group(0)!)) return room.id;
        }
        return 'F1_LAB8';
      }
    }
    return null;
  }

  static const List<DoorOpening> doors = [
    DoorOpening(roomId: 'G_STAIRS_N', side: WallSide.south, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'G_ELEV_N', side: WallSide.south, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'G_WORKSHOP', side: WallSide.east, position: 0.3, width: 0.1),
    DoorOpening(roomId: 'G_HALL', side: WallSide.west, position: 0.3, width: 0.1),
    DoorOpening(roomId: 'G_ELEV_S', side: WallSide.north, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'G_STAIRS_S', side: WallSide.north, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F1_WC_N', side: WallSide.south, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F1_STAIRS_N', side: WallSide.south, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F1_ELEV_N', side: WallSide.south, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'F1_EMRG_N', side: WallSide.south, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F1_H3', side: WallSide.east, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F1_H16', side: WallSide.west, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F1_WC_WU', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F1_WC_EU', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F1_H5', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F1_H19', side: WallSide.west, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F1_H14', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F1_H6', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F1_H20', side: WallSide.west, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F1_H13', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F1_WC_WL', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F1_WC_EL', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F1_LAB8', side: WallSide.east, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F1_LAB11', side: WallSide.west, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F1_WC_S', side: WallSide.north, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F1_ELEV_S', side: WallSide.north, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'F1_STAIRS_S', side: WallSide.north, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F1_EMRG_S', side: WallSide.north, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F2_WC_N', side: WallSide.south, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F2_STAIRS_N', side: WallSide.south, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F2_ELEV_N', side: WallSide.south, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'F2_EMRG_N', side: WallSide.south, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F2_H3', side: WallSide.east, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F2_H17', side: WallSide.west, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F2_WC_WU', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_WC_EU', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_H5', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_H20', side: WallSide.west, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F2_H15', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_H6', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_H21', side: WallSide.west, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F2_H14', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_WC_WL', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_WC_EL', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_H8', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_H9', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_H13', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_H12', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F2_WC_S', side: WallSide.north, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F2_ELEV_S', side: WallSide.north, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'F2_STAIRS_S', side: WallSide.north, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F2_EMRG_S', side: WallSide.north, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F3_WC_N', side: WallSide.south, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F3_STAIRS_N', side: WallSide.south, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F3_ELEV_N', side: WallSide.south, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'F3_EMRG_N', side: WallSide.south, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F3_H13', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H14', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H10', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H9', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_WC_WU', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_WC_EU', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H16', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H24', side: WallSide.west, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F3_H7', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H17', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H23', side: WallSide.west, position: 0.5, width: 0.12),
    DoorOpening(roomId: 'F3_H6', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_WC_WL', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_WC_EL', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H19', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H20', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H4', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_H3', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F3_WC_S', side: WallSide.north, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F3_ELEV_S', side: WallSide.north, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'F3_STAIRS_S', side: WallSide.north, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F3_EMRG_S', side: WallSide.north, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F4_WC_N', side: WallSide.south, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F4_STAIRS_N', side: WallSide.south, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F4_ELEV_N', side: WallSide.south, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'F4_EMRG_N', side: WallSide.south, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F4_ADMIN', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_HEAD_IME', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_HEAD_EE', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_RECEP_N', side: WallSide.west, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F4_EMPTY_N', side: WallSide.east, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F4_SEC_IME', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_WC_ER', side: WallSide.west, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F4_WC_WU', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_WC_EU', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_IT', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_SEC_EE', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_MAIL', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_MEETING', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_STATIONERY', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_STAT_ADMIN', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_FIELD', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_COPY', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_WC_WL', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_WC_EL', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_SEC_CS', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_EMPTY_S', side: WallSide.west, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F4_RECEP_S', side: WallSide.east, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F4_SEC_ENV', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_HEAD_CS', side: WallSide.east, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_HEAD_ENV', side: WallSide.west, position: 0.5, width: 0.2),
    DoorOpening(roomId: 'F4_WC_S', side: WallSide.north, position: 0.5, width: 0.25),
    DoorOpening(roomId: 'F4_ELEV_S', side: WallSide.north, position: 0.5, width: 0.4),
    DoorOpening(roomId: 'F4_STAIRS_S', side: WallSide.north, position: 0.5, width: 0.3),
    DoorOpening(roomId: 'F4_EMRG_S', side: WallSide.north, position: 0.5, width: 0.3),
  ];

  static List<DoorOpening> doorsForRoom(String roomId) => doors.where((door) => door.roomId == roomId).toList();

  static List<DoorOpening> doorsForFloor(int floor) {
    final roomIds = roomsForFloor(floor).map((room) => room.id).toSet();
    return doors.where((door) => roomIds.contains(door.roomId)).toList();
  }

  static double _dist(double x1, double y1, double x2, double y2) {
    return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
  }

  static List<NavNode> get allNodes {
    final nodes = <NavNode>[];

    void addFloor(int floor, String prefix, List<_RoomNav> rooms) {
      const yValues = [1.75, 4.25, 5.5, 6.75, 9.25, 11.75, 14.25, 16.75, 19.25, 20.5, 21.75, 24.25];
      for (var index = 0; index < yValues.length; index++) {
        nodes.add(NavNode(id: '${prefix}_ws$index', x: 9, y: yValues[index], floor: floor));
        nodes.add(NavNode(id: '${prefix}_es$index', x: 21, y: yValues[index], floor: floor));
      }
      nodes.add(NavNode(id: '${prefix}_stn', x: 13, y: 1.75, floor: floor));
      nodes.add(NavNode(id: '${prefix}_eln', x: 16.5, y: 1.75, floor: floor));
      nodes.add(NavNode(id: '${prefix}_els', x: 13, y: 24.25, floor: floor));
      nodes.add(NavNode(id: '${prefix}_sts', x: 16.5, y: 24.25, floor: floor));
      for (final room in rooms) {
        nodes.add(NavNode(id: '${prefix}_${room.tag}', x: room.x, y: room.y, floor: floor, roomId: room.roomId));
      }
      if (prefix != 'g') {
        nodes.add(NavNode(id: '${prefix}_emrg_n_mid', x: 16.75, y: 1.1, floor: floor));
      }
    }

    addFloor(0, 'g', const [
      _RoomNav('workshop', 5, 20.5, 'G_WORKSHOP'),
      _RoomNav('hall', 25, 20.5, 'G_HALL'),
      _RoomNav('entrance_s', 28.75, 13, 'G_ENTRANCE_S'),
      _RoomNav('entrance_w', 15, 27.25, 'G_ENTRANCE_W'),
      _RoomNav('entrance_e', 15, 1.75, 'G_ENTRANCE_E'),
    ]);
    addFloor(1, 'f1', const [
      _RoomNav('wc_n', 9.5, 1.75, 'F1_WC_N'),
      _RoomNav('emrg_n', 20.5, 1.75, 'F1_EMRG_N'),
      _RoomNav('h3', 7.5, 5.5, 'F1_H3'),
      _RoomNav('h16', 22.5, 5.5, 'F1_H16'),
      _RoomNav('wc_wu', 7.5, 9.25, 'F1_WC_WU'),
      _RoomNav('wc_eu', 22.5, 9.25, 'F1_WC_EU'),
      _RoomNav('h5', 7.5, 11.75, 'F1_H5'),
      _RoomNav('h19', 10, 11.75, 'F1_H19'),
      _RoomNav('h14', 22.5, 11.75, 'F1_H14'),
      _RoomNav('h6', 7.5, 14.25, 'F1_H6'),
      _RoomNav('h20', 10, 14.25, 'F1_H20'),
      _RoomNav('h13', 22.5, 14.25, 'F1_H13'),
      _RoomNav('wc_wl', 7.5, 16.75, 'F1_WC_WL'),
      _RoomNav('wc_el', 22.5, 16.75, 'F1_WC_EL'),
      _RoomNav('lab8', 7.5, 20.5, 'F1_LAB8'),
      _RoomNav('lab11', 22.5, 20.5, 'F1_LAB11'),
      _RoomNav('wc_s', 9.5, 24.25, 'F1_WC_S'),
      _RoomNav('emrg_s', 20.5, 24.25, 'F1_EMRG_S'),
    ]);
    addFloor(2, 'f2', const [
      _RoomNav('wc_n', 9.5, 1.75, 'F2_WC_N'),
      _RoomNav('emrg_n', 20.5, 1.75, 'F2_EMRG_N'),
      _RoomNav('h3', 7.5, 5.5, 'F2_H3'),
      _RoomNav('h17', 22.5, 5.5, 'F2_H17'),
      _RoomNav('wc_wu', 7.5, 9.25, 'F2_WC_WU'),
      _RoomNav('wc_eu', 22.5, 9.25, 'F2_WC_EU'),
      _RoomNav('h5', 7.5, 11.75, 'F2_H5'),
      _RoomNav('h20', 10, 11.75, 'F2_H20'),
      _RoomNav('h15', 22.5, 11.75, 'F2_H15'),
      _RoomNav('h6', 7.5, 14.25, 'F2_H6'),
      _RoomNav('h21', 10, 14.25, 'F2_H21'),
      _RoomNav('h14', 22.5, 14.25, 'F2_H14'),
      _RoomNav('wc_wl', 7.5, 16.75, 'F2_WC_WL'),
      _RoomNav('wc_el', 22.5, 16.75, 'F2_WC_EL'),
      _RoomNav('h8', 7.5, 19.25, 'F2_H8'),
      _RoomNav('h9', 7.5, 21.75, 'F2_H9'),
      _RoomNav('h13', 22.5, 19.25, 'F2_H13'),
      _RoomNav('h12', 22.5, 21.75, 'F2_H12'),
      _RoomNav('wc_s', 9.5, 24.25, 'F2_WC_S'),
      _RoomNav('emrg_s', 20.5, 24.25, 'F2_EMRG_S'),
    ]);
    addFloor(3, 'f3', const [
      _RoomNav('wc_n', 9.5, 1.75, 'F3_WC_N'),
      _RoomNav('emrg_n', 20.5, 1.75, 'F3_EMRG_N'),
      _RoomNav('h13', 7.5, 4.25, 'F3_H13'),
      _RoomNav('h14', 7.5, 6.75, 'F3_H14'),
      _RoomNav('h10', 22.5, 4.25, 'F3_H10'),
      _RoomNav('h9', 22.5, 6.75, 'F3_H9'),
      _RoomNav('wc_wu', 7.5, 9.25, 'F3_WC_WU'),
      _RoomNav('wc_eu', 22.5, 9.25, 'F3_WC_EU'),
      _RoomNav('h16', 7.5, 11.75, 'F3_H16'),
      _RoomNav('h24', 10, 11.75, 'F3_H24'),
      _RoomNav('h7', 22.5, 11.75, 'F3_H7'),
      _RoomNav('h17', 7.5, 14.25, 'F3_H17'),
      _RoomNav('h23', 10, 14.25, 'F3_H23'),
      _RoomNav('h6', 22.5, 14.25, 'F3_H6'),
      _RoomNav('wc_wl', 7.5, 16.75, 'F3_WC_WL'),
      _RoomNav('wc_el', 22.5, 16.75, 'F3_WC_EL'),
      _RoomNav('h19', 7.5, 19.25, 'F3_H19'),
      _RoomNav('h20', 7.5, 21.75, 'F3_H20'),
      _RoomNav('h4', 22.5, 19.25, 'F3_H4'),
      _RoomNav('h3', 22.5, 21.75, 'F3_H3'),
      _RoomNav('wc_s', 9.5, 24.25, 'F3_WC_S'),
      _RoomNav('emrg_s', 20.5, 24.25, 'F3_EMRG_S'),
    ]);
    addFloor(4, 'f4', const [
      _RoomNav('wc_n', 9.5, 1.75, 'F4_WC_N'),
      _RoomNav('emrg_n', 20.5, 1.75, 'F4_EMRG_N'),
      _RoomNav('admin', 7.5, 4.25, 'F4_ADMIN'),
      _RoomNav('head_ime', 22.5, 4.25, 'F4_HEAD_IME'),
      _RoomNav('head_ee', 7.5, 6.75, 'F4_HEAD_EE'),
      _RoomNav('recep_n', 10, 6.75, 'F4_RECEP_N'),
      _RoomNav('sec_ime', 22.5, 6.75, 'F4_SEC_IME'),
      _RoomNav('wc_wu', 7.5, 9.25, 'F4_WC_WU'),
      _RoomNav('wc_eu', 22.5, 9.25, 'F4_WC_EU'),
      _RoomNav('it', 7.5, 11.75, 'F4_IT'),
      _RoomNav('sec_ee', 10, 11.75, 'F4_SEC_EE'),
      _RoomNav('mail', 20, 11.75, 'F4_MAIL'),
      _RoomNav('meeting', 22.5, 11.75, 'F4_MEETING'),
      _RoomNav('stationery', 7.5, 14.25, 'F4_STATIONERY'),
      _RoomNav('stat_admin', 10, 14.25, 'F4_STAT_ADMIN'),
      _RoomNav('field', 20, 14.25, 'F4_FIELD'),
      _RoomNav('copy', 22.5, 14.25, 'F4_COPY'),
      _RoomNav('wc_wl', 7.5, 16.75, 'F4_WC_WL'),
      _RoomNav('wc_el', 22.5, 16.75, 'F4_WC_EL'),
      _RoomNav('sec_cs', 7.5, 19.25, 'F4_SEC_CS'),
      _RoomNav('recep_s', 15, 19.25, 'F4_RECEP_S'),
      _RoomNav('sec_env', 22.5, 19.25, 'F4_SEC_ENV'),
      _RoomNav('head_cs', 7.5, 21.75, 'F4_HEAD_CS'),
      _RoomNav('head_env', 22.5, 21.75, 'F4_HEAD_ENV'),
      _RoomNav('wc_s', 9.5, 24.25, 'F4_WC_S'),
      _RoomNav('emrg_s', 20.5, 24.25, 'F4_EMRG_S'),
    ]);

    return nodes;
  }

  static List<NavEdge> buildEdges() {
    final nodes = allNodes;
    final nodeMap = {for (final node in nodes) node.id: node};
    final edges = <NavEdge>[];

    void add(String from, String to, {bool transition = false}) {
      final fromNode = nodeMap[from]!;
      final toNode = nodeMap[to]!;
      final weight = _dist(fromNode.x, fromNode.y, toNode.x, toNode.y);
      edges.add(NavEdge(fromId: from, toId: to, weight: transition ? weight + 12 : weight, isFloorTransition: transition));
    }

    for (final prefix in ['g', 'f1', 'f2', 'f3', 'f4']) {
      for (var index = 0; index < 11; index++) {
        add('${prefix}_ws$index', '${prefix}_ws${index + 1}');
        add('${prefix}_es$index', '${prefix}_es${index + 1}');
      }
      add('${prefix}_ws0', '${prefix}_stn');
      add('${prefix}_stn', '${prefix}_eln');
      add('${prefix}_eln', '${prefix}_es0');
      add('${prefix}_ws4', '${prefix}_es4');
      add('${prefix}_ws7', '${prefix}_es7');
      add('${prefix}_ws11', '${prefix}_els');
      add('${prefix}_els', '${prefix}_sts');
      add('${prefix}_sts', '${prefix}_es11');

      if (prefix == 'g') {
        add('g_entrance_s', 'g_sts');
        add('g_entrance_s', 'g_els');
        add('g_entrance_e', 'g_stn');
        add('g_entrance_e', 'g_eln');
      } else {
        add('${prefix}_emrg_s', '${prefix}_sts');
        add('${prefix}_emrg_s', '${prefix}_els');
        add('${prefix}_emrg_n', '${prefix}_emrg_n_mid');
        add('${prefix}_emrg_n_mid', '${prefix}_stn');
        add('${prefix}_emrg_n_mid', '${prefix}_eln');
      }
    }

    void connectRooms(String prefix) {
      for (final node in nodes.where((node) => node.id.startsWith('${prefix}_') && node.roomId != null)) {
        final spinePrefix = node.x <= 15 ? '${prefix}_ws' : '${prefix}_es';
        NavNode? best;
        var bestDistance = double.infinity;
        for (final spineNode in nodes.where((spine) => spine.id.startsWith(spinePrefix) && spine.floor == node.floor && spine.roomId == null)) {
          final distance = (spineNode.y - node.y).abs();
          if (distance < bestDistance) {
            bestDistance = distance;
            best = spineNode;
          }
        }
        if (best != null) add(node.id, best.id);
      }
    }

    for (final prefix in ['g', 'f1', 'f2', 'f3', 'f4']) {
      connectRooms(prefix);
    }

    const floorPrefixes = ['g', 'f1', 'f2', 'f3', 'f4'];
    for (var index = 0; index < floorPrefixes.length - 1; index++) {
      final current = floorPrefixes[index];
      final next = floorPrefixes[index + 1];
      add('${current}_stn', '${next}_stn', transition: true);
      add('${current}_eln', '${next}_eln', transition: true);
      add('${current}_sts', '${next}_sts', transition: true);
      add('${current}_els', '${next}_els', transition: true);
    }

    return edges;
  }

  static NavNode? nodeForRoom(String roomId) {
    try {
      return allNodes.firstWhere((node) => node.roomId == roomId);
    } catch (_) {
      return null;
    }
  }
}

class _RoomNav {
  final String tag;
  final double x;
  final double y;
  final String roomId;

  const _RoomNav(this.tag, this.x, this.y, this.roomId);
}
