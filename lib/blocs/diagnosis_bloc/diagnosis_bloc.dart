import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:khungulanga_app/util/common.dart';
import 'package:meta/meta.dart';
import '../../models/diagnosis.dart';
import '../../repositories/diagnosis_repository.dart';
part 'diagnosis_event.dart';
part 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  final DiagnosisRepository _repository;

  DiagnosisBloc({required DiagnosisRepository repository})
      : _repository = repository,
        super(DiagnosisInitial([]));

  @override
  Stream<DiagnosisState> mapEventToState(DiagnosisEvent event) async* {
    if (event is FetchDiagnoses) {
      yield DiagnosisLoading(_repository.diagnoses);

      try {
        final diagnoses = await _repository.fetchDiagnoses();
        yield DiagnosisLoaded(diagnoses);
      } catch (e) {
        yield DiagnosisError(_repository.diagnoses, message: 'Failed to load diagnoses');
      }
    } else if (event is DeleteDiagnosis) {
      yield DiagnosisDeleting(_repository.diagnoses, event.diagnosis);

      try {
        await _repository.delete(event.diagnosis);
        final diagnoses = await _repository.fetchDiagnoses();
        yield DiagnosisDeleted(diagnoses);
      } catch (e) {
        yield DiagnosisDeletingError(_repository.diagnoses, message: 'Failed to delete diagnosis');
      }
    } else if (event is DeleteDiagnosisPressed) {
      yield ConfirmingDiagnosisDelete(_repository.diagnoses, event.diagnosis);
    } else if (event is Diagnose) {
      try {
        yield Diagnosing(_repository.diagnoses);
        final diagnosis = await DiagnosisRepository().diagnose(event.data);
        yield DiagnosisSuccess(_repository.diagnoses, diagnosis);
      } on AppException catch (e) {
        log("Error ${e.code}", error: e);
        if (e.code == "206") {
          yield DiagnosingError206(_repository.diagnoses, e.toString());
        }
      } catch (e) {
        log("Error", error: e);
        yield DiagnosingErrorAny(_repository.diagnoses, e.toString().startsWith("Exception")? e.toString().substring(11) : e.toString());
      }
    }
  }
}