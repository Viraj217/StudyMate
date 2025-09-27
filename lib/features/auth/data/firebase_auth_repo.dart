// /*
// FIREBASE IS OUR BACKEND FOR AUTHENTICATION AND STORAGE
//  */

// import 'package:studymate/features/auth/domain/entities/app_user.dart';
// import 'package:studymate/features/auth/domain/repos/auth_repo.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class FirebaseAuthRepo implements AuthRepo {
//   // access to firebase
//   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//   // LOGIN
//   @override
//   Future<AppUser?> loginWithEmailPassword(String email, String Password) async {
//     try {
//       //attempt to sign in
//       UserCredential userCredential = await firebaseAuth
//           .signInWithEmailAndPassword(email: email, password: Password);

//       // Check if the user is not null after sign-in
//       if (userCredential.user != null) {
//         AppUser user = AppUser(
//           uid: userCredential
//               .user!
//               .uid, // Access user from the instance userCredential
//           email: email,
//           name: firebaseUser,
//         );
//         return user;
//       } else {
//         throw Exception('Login successful, but user data is null.');
//       }
//     } catch (e) {
//       throw Exception('Login Failed: $e');
//     }
//   }

//   // REGISTER
//   @override
//   Future<AppUser?> registerWithEmailPassword(
//     String name,
//     String email,
//     String Password,
//   ) async {
//     try {
//       //attempt to sign up
//       UserCredential userCredential = await firebaseAuth
//           .createUserWithEmailAndPassword(email: email, password: Password);

//       // Set displayName in FirebaseAuth
//       await userCredential.user?.updateDisplayName(name);
//       await userCredential.user?.reload(); // reload to apply changes

//       // create user
//       AppUser user = AppUser(
//         name: name,
//         uid: userCredential.user!.uid,
//         email: email,
//       );

//       return user;
//     } catch (e) {
//       throw Exception('Registration Failed: $e');
//     }
//   }

//   //DELETE
//   @override
//   Future<void> deleteAccount() async {
//     try {
//       final user = firebaseAuth.currentUser;
//       if (user == null) throw Exception('No user logged in...');

//       await user.delete();

//       await logout();
//     } catch (e) {
//       throw Exception('Deletion Failed: $e');
//     }
//   }

//   // GET CURRENT USER
//   @override
//   Future<AppUser?> getCurrentUser() async {
//     //get current user from firebase
//     final firebaseUser = firebaseAuth.currentUser;

//     // no logged in user
//     if (firebaseUser == null) return null;
//     //logged in user exists
//     return AppUser(
//       name: firebaseUser.displayName ?? '',
//       uid: firebaseUser.uid,
//       email: firebaseUser.email!,
//     );
//   }

//   //LOGOUT
//   @override
//   Future<void> logout() async {
//     await firebaseAuth.signOut();
//   }

//   //PASSWORD RESET
//   @override
//   Future<String> sendPasswordResetEmail(String email) async {
//     try {
//       await firebaseAuth.sendPasswordResetEmail(email: email);
//       return "Password reset email! Check your inbox.";
//     } catch (e) {
//       throw Exception('Error sending password reset email: $e');
//     }
//   }

//   @override
//   Future<AppUser?> signInWithGoogle() {
//     // TODO: implement signInWithGoogle
//     throw UnimplementedError();
//   }
// }

/*
FIREBASE IS OUR BACKEND FOR AUTHENTICATION AND STORAGE
*/

import 'package:studymate/features/auth/domain/entities/app_user.dart';
import 'package:studymate/features/auth/domain/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepo implements AuthRepo {
  // Access to FirebaseAuth
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // ===================== LOGIN =====================
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // Attempt to sign in
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload user to ensure displayName is updated
      await userCredential.user?.reload();
      final firebaseUser = firebaseAuth.currentUser;

      if (firebaseUser != null) {
        return AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? '',
        );
      } else {
        throw Exception('Login successful, but user data is null.');
      }
    } catch (e) {
      throw Exception('Login Failed: $e');
    }
  }

  // ===================== REGISTER =====================
  @override
  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      // Attempt to sign up
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set the displayName in FirebaseAuth
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload(); // reload to apply changes

      final firebaseUser = firebaseAuth.currentUser;

      return AppUser(
        uid: firebaseUser!.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName ?? '',
      );
    } catch (e) {
      throw Exception('Registration Failed: $e');
    }
  }

  // ===================== GET CURRENT USER =====================
  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: firebaseUser.displayName ?? '',
    );
  }

  // ===================== LOGOUT =====================
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  // ===================== DELETE ACCOUNT =====================
  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in...');

      await user.delete();
      await logout();
    } catch (e) {
      throw Exception('Deletion Failed: $e');
    }
  }

  // ===================== PASSWORD RESET =====================
  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your inbox.";
    } catch (e) {
      throw Exception('Error sending password reset email: $e');
    }
  }

  // ===================== GOOGLE SIGN-IN =====================
  @override
  Future<AppUser?> signInWithGoogle() {
    // TODO: implement signInWithGoogle using google_sign_in package
    throw UnimplementedError();
  }
}
