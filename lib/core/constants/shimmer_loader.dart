import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:flutter/material.dart";
import 'package:shimmer/shimmer.dart';

class ShimmerLoaderWidet extends ConsumerWidget {
  const ShimmerLoaderWidet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Shimmer.fromColors(
          baseColor:const Color.fromARGB(44, 177, 190, 255)!,
          highlightColor:const Color.fromARGB(85, 174, 204, 255)!,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(44, 177, 190, 255)!,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                ),
                const SizedBox(height: 25),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                ),
                const SizedBox(height: 25),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                ),
                const SizedBox(height: 25),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerLoaderContainer extends ConsumerWidget {
  const ShimmerLoaderContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        baseColor: const Color.fromARGB(44, 177, 190, 255)!,
        highlightColor: const Color.fromARGB(85, 174, 204, 255)!,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color.fromARGB(44, 177, 190, 255)!,
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
        ),
      ),
    );
  }
}
