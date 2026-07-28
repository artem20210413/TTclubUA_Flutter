import 'package:flutter/material.dart';

import '../../Storage/Cache/DeviceInsetsCache.dart';
import '../TTLoading.dart';
import '../../api/routs/Dto/City/CityMapPointDto.dart';
import '../../api/routs/Dto/City/CityMemberDto.dart';
import '../../api/routs/cities/CityServices.dart';
import '../../config/default.dart';
import '../../pages/Nav/Mention/Profile.dart';
import '../../utils/RetrySnackBar.dart';
import '../TTNeumorphicBox.dart';
import '../card/UserAvatar.dart';

/// Opens the paginated city-members bottom sheet for [cityPoint] (FR-010-FR-013, FR-018).
Future<void> showCityMembersBottomSheet(
  BuildContext context,
  CityMapPointDto cityPoint,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: TTColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => CityMembersBottomSheet(cityPoint: cityPoint),
  );
}

class CityMembersBottomSheet extends StatefulWidget {
  final CityMapPointDto cityPoint;

  const CityMembersBottomSheet({super.key, required this.cityPoint});

  @override
  State<CityMembersBottomSheet> createState() => _CityMembersBottomSheetState();
}

class _CityMembersBottomSheetState extends State<CityMembersBottomSheet> {
  final List<CityMemberDto> _members = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;

  /// Incremented on every fetch to let stale, in-flight requests detect
  /// they've been superseded and ignore their result (Edge Cases).
  int _requestToken = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
    _fetchPage(page: 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage({required int page, bool append = false}) async {
    final requestToken = ++_requestToken;
    setState(() {
      if (append) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    final result = await CityServices.fetchCityMembers(
      context,
      widget.cityPoint.id,
      page: page,
    );

    if (!mounted || requestToken != _requestToken) return;

    if (result == null) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      showRetrySnackBar(
        context,
        'Не вдалося завантажити учасників міста',
        onRetry: () => _fetchPage(page: page, append: append),
      );
      return;
    }

    setState(() {
      if (append) {
        _members.addAll(result);
      } else {
        _members
          ..clear()
          ..addAll(result);
      }
      _page = page;
      _hasMore = result.length >= 10;
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  void _loadMore() {
    _fetchPage(page: _page + 1, append: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: DeviceInsetsCache.viewPaddingBottom + 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TTColors.text_secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.cityPoint.name, style: TTTextStyle.title18),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.cityPoint.usersCount} учасник(-ів)',
                style: TTTextStyle.subtitle,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: _isLoading
                  ? const Center(child: TTLoading())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _members.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _members.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: TTLoading()),
                          );
                        }
                        return _MemberRow(member: _members[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final CityMemberDto member;

  const _MemberRow({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TTNeumorphicBox(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        radius: 20,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Profile(id: member.id)),
            );
          },
          child: Row(
            children: [
              UserAvatar(
                name: member.name,
                imageUrl: member.hasDefaultAvatar ? null : member.profileImage,
                radius: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: TTTextStyle.title18.copyWith(fontSize: 16)),
                    // if (member.roles.isNotEmpty)
                    //   Text(member.roles.join(', '), style: TTTextStyle.caption),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: TTColors.text_secondary, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
