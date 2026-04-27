import 'package:dartz/dartz.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<Project>>> getProjects();
  Future<Either<Failure, Project>> getProjectById(String id);
  Future<Either<Failure, Project>> createProject(Project project);
  Future<Either<Failure, Project>> updateProject(Project project);
  Future<Either<Failure, void>> deleteProject(String id);
  Future<Either<Failure, void>> archiveProject(String id);
  Future<Either<Failure, List<Project>>> getProjectsByStatus(String status);
  Stream<List<Project>> watchProjects();
}
