<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tbl_permission', function (Blueprint $table) {
            $table->bigIncrements('v_permissionId');

            $table->string('v_permissionCode', 100)->unique();
            $table->string('v_permissionName', 150);
            $table->string('v_permissionDescription', 255)->nullable();

            $table->dateTime('v_createdAt')->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_permission');
    }
};